// Modelos de datos. En el original había ~30 clases generadas (jsonschema2pojo)
// con todos los campos de la API y Gson los rellenaba solo. Aquí se escriben
// a mano y solo con los campos que la app usa de verdad.

/// Película: sirve tanto para los listados (movie/popular, similar, search...)
/// como para el detalle (movie/{id}), que trae además géneros, estudios y duración.
class Pelicula {
  final int id;
  final String titulo;
  final String? poster;
  final String? fondo;
  final double votoMedio;
  final int votos;
  final double popularidad;
  final String descripcion;
  final String fechaEstreno;
  final int? duracion; // minutos
  final List<String> generos;
  final List<String> estudios;

  Pelicula({
    required this.id,
    required this.titulo,
    this.poster,
    this.fondo,
    this.votoMedio = 0,
    this.votos = 0,
    this.popularidad = 0,
    this.descripcion = '',
    this.fechaEstreno = '',
    this.duracion,
    this.generos = const [],
    this.estudios = const [],
  });

  factory Pelicula.fromJson(Map<String, dynamic> json) => Pelicula(
        id: json['id'] as int,
        titulo: (json['title'] ?? '') as String,
        poster: json['poster_path'] as String?,
        fondo: json['backdrop_path'] as String?,
        votoMedio: (json['vote_average'] as num?)?.toDouble() ?? 0,
        votos: (json['vote_count'] as num?)?.toInt() ?? 0,
        popularidad: (json['popularity'] as num?)?.toDouble() ?? 0,
        descripcion: (json['overview'] ?? '') as String,
        fechaEstreno: (json['release_date'] ?? '') as String,
        duracion: (json['runtime'] as num?)?.toInt(),
        generos: _nombres(json['genres']),
        estudios: _nombres(json['production_companies']),
      );
}

class Serie {
  final int id;
  final String nombre;
  final String? poster;
  final String? fondo;
  final double votoMedio;
  final int votos;
  final double popularidad;
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
    this.fondo,
    this.votoMedio = 0,
    this.votos = 0,
    this.popularidad = 0,
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
        fondo: json['backdrop_path'] as String?,
        votoMedio: (json['vote_average'] as num?)?.toDouble() ?? 0,
        votos: (json['vote_count'] as num?)?.toInt() ?? 0,
        popularidad: (json['popularity'] as num?)?.toDouble() ?? 0,
        descripcion: (json['overview'] ?? '') as String,
        primeraEmision: (json['first_air_date'] ?? '') as String,
        temporadas: (json['number_of_seasons'] as num?)?.toInt(),
        episodios: (json['number_of_episodes'] as num?)?.toInt(),
        estado: (json['status'] ?? '') as String,
        generos: _nombres(json['genres']),
        cadenas: _nombres(json['networks']),
      );
}

/// Persona del reparto (credits) o detalle de actor (person/{id}).
class Persona {
  final int id;
  final String nombre;
  final String? foto;
  final String? personaje;
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
    this.personaje,
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
        personaje: json['character'] as String?,
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

/// Lo que necesita una tarjeta, venga de una película o de una serie.
/// Permite usar las mismas listas, tarjetas y botones para los dos tipos
/// (en el original había PeliculaAdapter, SerieAdapter, CastPeliculaAdapter...).
class ElementoMedia {
  final int id;
  final String titulo;
  final String? poster;
  final String? fondo;
  final double votoMedio; // sobre 10
  final String fecha; // "aaaa-mm-dd" o vacía
  final bool esSerie;

  const ElementoMedia({
    required this.id,
    required this.titulo,
    required this.poster,
    required this.votoMedio,
    required this.esSerie,
    this.fondo,
    this.fecha = '',
  });

  /// Año de estreno ("2019") o cadena vacía si no se conoce.
  String get anio => fecha.length >= 4 ? fecha.substring(0, 4) : '';
}

extension PeliculaComoElemento on Pelicula {
  ElementoMedia get comoElemento => ElementoMedia(
        id: id,
        titulo: titulo,
        poster: poster,
        fondo: fondo,
        votoMedio: votoMedio,
        fecha: fechaEstreno,
        esSerie: false,
      );
}

extension SerieComoElemento on Serie {
  ElementoMedia get comoElemento => ElementoMedia(
        id: id,
        titulo: nombre,
        poster: poster,
        fondo: fondo,
        votoMedio: votoMedio,
        fecha: primeraEmision,
        esSerie: true,
      );
}

/// Convierte [{id:.., name:..}, ...] en una lista de nombres.
List<String> _nombres(dynamic lista) => ((lista as List?) ?? const [])
    .map((e) => (e as Map<String, dynamic>)['name']?.toString() ?? '')
    .where((n) => n.isNotEmpty)
    .toList();
