import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/modelos.dart';

/// Sustituye a la interfaz Retrofit TheMovieDBService.
/// En el original cada Activity creaba su propio Retrofit y encolaba llamadas
/// con callbacks (enqueue/onResponse/onFailure). Aquí cada método es async y
/// devuelve un Future: quien lo llama hace `await` o usa un FutureBuilder.
class TmdbService {
  TmdbService._();
  static final TmdbService instancia = TmdbService._();

  final http.Client _cliente = http.Client();

  /// Hace un GET y devuelve el JSON. Lanza una excepción si el código no es 200
  /// (en el original era el switch(response.code()) de cada callback).
  Future<Map<String, dynamic>> _get(String ruta, [Map<String, String>? extra]) async {
    if (Config.apiKey.isEmpty) {
      throw Exception('Falta la clave de TheMovieDB. '
          'Ejecuta con --dart-define-from-file=secrets.json');
    }
    final uri = Uri.parse('${Config.baseUrl}$ruta').replace(queryParameters: {
      'api_key': Config.apiKey,
      'language': Config.idioma,
      ...?extra,
    });
    final respuesta = await _cliente.get(uri);
    if (respuesta.statusCode != 200) {
      throw Exception('Error ${respuesta.statusCode} en $ruta');
    }
    return jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;
  }

  List<T> _lista<T>(Map<String, dynamic> json, String campo,
          T Function(Map<String, dynamic>) fromJson) =>
      ((json[campo] as List?) ?? const [])
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();

  // ---------- Películas ----------
  Future<List<Pelicula>> peliculasRecomendadas() async =>
      _lista(await _get('movie/popular'), 'results', Pelicula.fromJson);

  Future<List<Pelicula>> peliculasMejorValoradas() async =>
      _lista(await _get('movie/top_rated'), 'results', Pelicula.fromJson);

  /// Películas que están ahora en los cines del país del usuario.
  Future<List<Pelicula>> peliculasEnCines() async {
    final lista = _lista(
        await _get('movie/now_playing', {'region': Config.region}), 'results', Pelicula.fromJson);
    lista.sort((a, b) => b.popularidad.compareTo(a.popularidad));
    return lista;
  }

  /// Próximos estrenos en el país del usuario, del más cercano al más lejano.
  /// La API a veces incluye alguna ya estrenada, así que se quitan las pasadas.
  Future<List<Pelicula>> peliculasProximamente() async {
    final lista = _lista(
        await _get('movie/upcoming', {'region': Config.region}), 'results', Pelicula.fromJson);
    final hoy = DateTime.now().toIso8601String().substring(0, 10); // "aaaa-mm-dd"
    return lista.where((p) => p.fechaEstreno.compareTo(hoy) >= 0).toList()
      ..sort((a, b) => a.fechaEstreno.compareTo(b.fechaEstreno));
  }

  Future<Pelicula> pelicula(int id) async => Pelicula.fromJson(await _get('movie/$id'));

  Future<List<Persona>> repartoPelicula(int id) async =>
      _lista(await _get('movie/$id/credits'), 'cast', Persona.fromJson);

  Future<List<Pelicula>> peliculasSimilares(int id) async =>
      _lista(await _get('movie/$id/similar'), 'results', Pelicula.fromJson);

  Future<List<Trailer>> trailersPelicula(int id) async =>
      _lista(await _get('movie/$id/videos'), 'results', Trailer.fromJson);

  // ---------- Series ----------
  Future<List<Serie>> seriesRecomendadas() async =>
      _lista(await _get('tv/popular'), 'results', Serie.fromJson);

  Future<List<Serie>> seriesMejorValoradas() async =>
      _lista(await _get('tv/top_rated'), 'results', Serie.fromJson);

  /// Series que estrenan episodios esta semana.
  Future<List<Serie>> seriesEnEmision() async {
    final lista = _lista(await _get('tv/on_the_air'), 'results', Serie.fromJson);
    lista.sort((a, b) => b.popularidad.compareTo(a.popularidad));
    return lista;
  }

  Future<Serie> serie(int id) async => Serie.fromJson(await _get('tv/$id'));

  Future<List<Persona>> repartoSerie(int id) async =>
      _lista(await _get('tv/$id/credits'), 'cast', Persona.fromJson);

  Future<List<Serie>> seriesSimilares(int id) async =>
      _lista(await _get('tv/$id/similar'), 'results', Serie.fromJson);

  Future<List<Trailer>> trailersSerie(int id) async =>
      _lista(await _get('tv/$id/videos'), 'results', Trailer.fromJson);

  // ---------- Personas ----------
  Future<Persona> actor(int id) async => Persona.fromJson(await _get('person/$id'));

  /// En el original se leía el campo "crew" (trabajos detrás de cámara) en vez de
  /// "cast", por eso a muchos actores no les salían películas. Aquí se usa "cast".
  Future<List<Pelicula>> peliculasActor(int id) async =>
      _lista(await _get('person/$id/movie_credits'), 'cast', Pelicula.fromJson);

  Future<List<Serie>> seriesActor(int id) async =>
      _lista(await _get('person/$id/tv_credits'), 'cast', Serie.fromJson);

  // ---------- Búsqueda ----------
  Future<List<Pelicula>> buscarPeliculas(String texto) async =>
      _lista(await _get('search/movie', {'query': texto}), 'results', Pelicula.fromJson);

  Future<List<Serie>> buscarSeries(String texto) async =>
      _lista(await _get('search/tv', {'query': texto}), 'results', Serie.fromJson);
}
