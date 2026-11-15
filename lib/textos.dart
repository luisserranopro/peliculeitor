import 'config.dart';

/// Sustituye a res/values/strings.xml (inglés) y res/values-es/strings.xml (español).
/// Se elige según el idioma del dispositivo, igual que hacía Android.
class Textos {
  static bool get _es => Config.idioma == 'es';

  static String get peliculas => _es ? 'Películas' : 'Movies';
  static String get series => 'Series';
  static String get favoritos => _es ? 'Favoritos' : 'Favorites';

  static String get bienvenida =>
      _es ? 'Hola,\n¿Qué quieres ver?' : 'Hello, what do you want to watch?';
  static String get buscar => _es ? 'Buscar...' : 'Search...';
  static String get recomendadas => _es ? 'RECOMENDADAS PARA TI' : 'RECOMMENDED FOR YOU';
  static String get masValoradas => _es ? 'MÁS VALORADAS' : 'TOP RATED';

  static String get verTrailer => _es ? 'VER TRÁILER' : 'WATCH NOW';
  static String get estudio => _es ? 'Estudio' : 'Studio';
  static String get genero => _es ? 'Género' : 'Genre';
  static String get lanzamiento => _es ? 'Lanzamiento' : 'Release';
  static String get peliculasSimilares => _es ? 'Películas Similares' : 'Similar Movies';

  static String get favoritosTitulo =>
      _es ? '¡Series y películas favoritas!' : 'Favorite series and movies!';
  static String get seriesFavoritas => _es ? '¡SERIES FAVORITAS!' : 'FAVORITE SERIES!';
  static String get peliculasFavoritas => _es ? '¡PELÍCULAS FAVORITAS!' : 'FAVORITE MOVIES!';
  static String get sinFavoritos => _es ? 'Todavía no hay ninguna' : 'Nothing here yet';

  static String get cumpleanos => _es ? 'Cumpleaños' : 'Birthday';
  static String get lugarNacimiento => _es ? 'Lugar de nacimiento' : 'Place of birth';
  static String get popularidad => _es ? 'Popularidad' : 'Popularity';
  static String get conocidoPor => _es ? 'Conocido por' : 'Known for';
  static String get tambienConocido => _es ? 'También conocido como' : 'Also known as';
  static String get biografia => _es ? 'Biografía' : 'Biography';
  static String get peliculasActor =>
      _es ? 'Películas en las que aparece' : 'Movies in which appears';
  static String get seriesActor => _es ? 'Series en las que aparece' : 'Series in which appears';

  static String get temporadas => _es ? 'Temporadas' : 'Seasons';
  static String get episodios => _es ? 'Episodios' : 'Episodes';
  static String get estado => _es ? 'Estado' : 'Status';
  static String get seriesSimilares => _es ? 'Series Similares' : 'Similar Series';

  static String get reparto => _es ? 'Reparto' : 'Cast';
  static String get errorCarga =>
      _es ? 'No se han podido cargar los datos' : 'Could not load data';
  static String get reintentar => _es ? 'Reintentar' : 'Retry';
}
