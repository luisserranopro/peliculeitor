import 'config.dart';

/// Sustituye a res/values/strings.xml (inglés) y res/values-es/strings.xml (español).
/// Se elige según el idioma del dispositivo, igual que hacía Android.
class Textos {
  static bool get _es => Config.idioma == 'es';

  // Barra inferior
  static String get peliculas => _es ? 'Películas' : 'Movies';
  static String get series => 'Series';
  static String get misListas => _es ? 'Mis listas' : 'My lists';

  // Catálogo
  static String get saludo => _es ? 'Hola' : 'Hello';
  static String get queVer => _es ? '¿Qué quieres ver hoy?' : 'What do you want to watch today?';
  static String get buscarPeliculas => _es ? 'Buscar películas' : 'Search movies';
  static String get buscarSeries => _es ? 'Buscar series' : 'Search series';
  static String get destacadas => _es ? 'Destacadas' : 'Featured';
  static String get populares => _es ? 'Populares' : 'Popular';
  static String get masValoradas => _es ? 'Mejor valoradas' : 'Top rated';
  static String get sinResultados => _es ? 'No hay resultados' : 'No results';

  // Fichas
  static String get verTrailer => _es ? 'Tráiler' : 'Trailer';
  static String get favorito => _es ? 'Favorita' : 'Favorite';
  static String get quieroVer => _es ? 'Quiero ver' : 'Watchlist';
  static String get sinopsis => _es ? 'Sinopsis' : 'Overview';
  static String get leerMas => _es ? 'Leer más' : 'Read more';
  static String get leerMenos => _es ? 'Leer menos' : 'Show less';
  static String get reparto => _es ? 'Reparto' : 'Cast';
  static String get detalles => _es ? 'Detalles' : 'Details';
  static String get estudio => _es ? 'Estudio' : 'Studio';
  static String get cadena => _es ? 'Cadena' : 'Network';
  static String get lanzamiento => _es ? 'Estreno' : 'Release';
  static String get estado => _es ? 'Estado' : 'Status';
  static String get peliculasSimilares => _es ? 'Películas similares' : 'Similar movies';
  static String get seriesSimilares => _es ? 'Series similares' : 'Similar series';
  static String temporadas(int n) => _es
      ? '$n ${n == 1 ? 'temporada' : 'temporadas'}'
      : '$n ${n == 1 ? 'season' : 'seasons'}';
  static String episodios(int n) => _es
      ? '$n ${n == 1 ? 'episodio' : 'episodios'}'
      : '$n ${n == 1 ? 'episode' : 'episodes'}';
  static String get capitulos => _es ? 'Episodios' : 'Episodes';
  static String votos(int n) => _es ? '$n votos' : '$n votes';

  // Actor
  static String get cumpleanos => _es ? 'Nacimiento' : 'Born';
  static String get tambienConocido => _es ? 'También conocido como' : 'Also known as';
  static String get biografia => _es ? 'Biografía' : 'Biography';
  static String get peliculasActor => _es ? 'Películas' : 'Movies';
  static String get seriesActor => 'Series';

  // Mis listas
  static String get todo => _es ? 'Todo' : 'All';
  static String get favoritas => _es ? 'Favoritas' : 'Favorites';
  static String get pelicula => _es ? 'Película' : 'Movie';
  static String get serie => _es ? 'Serie' : 'Series';
  static String get yaLaHeVisto => _es ? 'Ya la he visto' : 'Watched it';
  static String get quitarFavorita => _es ? 'Quitar de favoritas' : 'Remove from favorites';
  static String get deshacer => _es ? 'Deshacer' : 'Undo';
  static String anadidaA(String lista) => _es ? 'Añadida a $lista' : 'Added to $lista';
  static String quitadaDe(String lista) => _es ? 'Quitada de $lista' : 'Removed from $lista';
  static String get vacioPorVer => _es
      ? 'Tu lista está vacía.\nPulsa «Quiero ver» en cualquier ficha para guardarla aquí.'
      : 'Your watchlist is empty.\nTap “Watchlist” on any title to save it here.';
  static String get vacioFavoritas => _es
      ? 'Aún no tienes favoritas.\nPulsa el corazón en cualquier ficha.'
      : 'No favorites yet.\nTap the heart on any title.';

  // Errores
  static String get errorCarga =>
      _es ? 'No se han podido cargar los datos' : 'Could not load data';
  static String get reintentar => _es ? 'Reintentar' : 'Retry';
}
