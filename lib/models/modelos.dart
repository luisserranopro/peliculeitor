// Modelos de datos. En el original había ~30 clases generadas (jsonschema2pojo)
// con todos los campos de la API y Gson los rellenaba solo. Aquí se escriben
// a mano y solo con los campos que la app usa de verdad.

/// Película: sirve tanto para los listados (movie/popular, similar, search...)
/// como para el detalle (movie/{id}), que trae además géneros y estudios.
class Pelicula {
  final int id;
  final String titulo;
  final String? poster;
  final double votoMedio;
  final String descripcion;
  final String fechaEstreno;
  final List<String> generos;
  final List<String> estudios;

  Pelicula({
    required this.id,
    required this.titulo,
    this.poster,
    this.votoMedio = 0,
    this.descripcion = '',
    this.fechaEstreno = '',
    this.generos = const [],
    this.estudios = const [],
  });

  factory Pelicula.fromJson(Map<String, dynamic> json) => Pelicula(
        id: json['id'] as int,
        titulo: (json['title'] ?? '') as String,
        poster: json['poster_path'] as String?,
        votoMedio: (json['vote_average'] as num?)?.toDouble() ?? 0,
        descripcion: (json['overview'] ?? '') as String,
        fechaEstreno: (json['release_date'] ?? '') as String,
        generos: _nombres(json['genres']),
        estudios: _nombres(json['production_companies']),
      );

  /// Igual que getRating() del original: la API puntúa sobre 10, las estrellas sobre 5.
  double get valoracion => votoMedio / 2;
}

class Serie {
  final int id;
  final String nombre;
  final String? poster;
  final double votoMedio;
  final String descripcion;
  final String primeraEmision;
  final int? temporadas;
  final int? episodios;
  final String estado;
  final List<String> generos;
  final List<String> cadenas;

  Serie({
    required this.id,
    required this.nombre,
    this.poster,
    this.votoMedio = 0,
    this.descripcion = '',
    this.primeraEmision = '',
    this.temporadas,
    this.episodios,
    this.estado = '',
    this.generos = const [],
    this.cadenas = const [],
  });

  factory Serie.fromJson(Map<String, dynamic> json) => Serie(
        id: json['id'] as int,
        nombre: (json['name'] ?? '') as String,
        poster: json['poster_path'] as String?,
        votoMedio: (json['vote_average'] as num?)?.toDouble() ?? 0,
        descripcion: (json['overview'] ?? '') as String,
        primeraEmision: (json['first_air_date'] ?? '') as String,
        temporadas: json['number_of_seasons'] as int?,
        episodios: json['number_of_episodes'] as int?,
        estado: (json['status'] ?? '') as String,
        generos: _nombres(json['genres']),
        cadenas: _nombres(json['networks']),
      );

  double get valoracion => votoMedio / 2;
}

/// Persona del reparto (credits) o detalle de actor (person/{id}).
class Persona {
  final int id;
  final String nombre;
  final String? foto;
  final String? cumpleanos;
  final String? lugarNacimiento;
  final double? popularidad;
  final String? conocidoPor;
  final List<String> tambienConocido;
  final String biografia;

  Persona({
    required this.id,
    required this.nombre,
    this.foto,
    this.cumpleanos,
    this.lugarNacimiento,
    this.popularidad,
    this.conocidoPor,
    this.tambienConocido = const [],
    this.biografia = '',
  });

  factory Persona.fromJson(Map<String, dynamic> json) => Persona(
        id: json['id'] as int,
        nombre: (json['name'] ?? '') as String,
        foto: json['profile_path'] as String?,
        cumpleanos: json['birthday'] as String?,
        lugarNacimiento: json['place_of_birth'] as String?,
        popularidad: (json['popularity'] as num?)?.toDouble(),
        conocidoPor: json['known_for_department'] as String?,
        tambienConocido: ((json['also_known_as'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        biografia: (json['biography'] ?? '') as String,
      );
}

/// Vídeo de movie/{id}/videos o tv/{id}/videos.
class Trailer {
  final String clave;
  final String sitio;
  final String tipo;

  Trailer({required this.clave, required this.sitio, required this.tipo});

  factory Trailer.fromJson(Map<String, dynamic> json) => Trailer(
        clave: (json['key'] ?? '') as String,
        sitio: (json['site'] ?? '') as String,
        tipo: (json['type'] ?? '') as String,
      );

  String get urlYoutube => 'https://www.youtube.com/watch?v=$clave';
}

/// Lo que necesita una tarjeta de póster, venga de una película o de una serie.
/// Permite usar la misma lista y la misma tarjeta para los dos tipos
/// (en el original había PeliculaAdapter, SerieAdapter, CastPeliculaAdapter...).
class ElementoMedia {
  final int id;
  final String titulo;
  final String? poster;
  final double valoracion;
  final bool esSerie;

  const ElementoMedia({
    required this.id,
    required this.titulo,
    required this.poster,
    required this.valoracion,
    required this.esSerie,
  });
}

extension PeliculaComoElemento on Pelicula {
  ElementoMedia get comoElemento => ElementoMedia(
      id: id, titulo: titulo, poster: poster, valoracion: valoracion, esSerie: false);
}

extension SerieComoElemento on Serie {
  ElementoMedia get comoElemento => ElementoMedia(
      id: id, titulo: nombre, poster: poster, valoracion: valoracion, esSerie: true);
}

/// Convierte [{id:.., name:..}, ...] en una lista de nombres.
List<String> _nombres(dynamic lista) => ((lista as List?) ?? const [])
    .map((e) => (e as Map<String, dynamic>)['name']?.toString() ?? '')
    .where((n) => n.isNotEmpty)
    .toList();
