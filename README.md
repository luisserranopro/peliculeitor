# Peliculeitor (Flutter)

Migración a Flutter de la app Android en Java *peliculeitor* (2DAM 2023/24).
Hace lo mismo que la original: películas y series populares y mejor valoradas,
búsqueda, fichas de detalle con reparto, similares y tráiler, ficha de actor y
dos listas personales guardadas en SQLite: **Favoritas** y **Quiero ver**. Los datos vienen de la API de TheMovieDB.

## Cómo ponerla en marcha

Hace falta tener Flutter instalado (`flutter doctor` sin errores para Android).

1. Descomprime esta carpeta y entra en ella:
   ```
   cd peliculeitor_flutter
   ```
2. Genera las carpetas de plataforma (`android/`, `ios/`...). Como `lib/` y
   `pubspec.yaml` ya existen, `flutter create` solo añade lo que falta:
   ```
   flutter create --org com.example --project-name peliculeitor --platforms android,ios .
   ```
3. Abre `android/app/src/main/AndroidManifest.xml` y añade estas dos cosas:
   - Justo dentro de `<manifest ...>`, antes de `<application>`:
     ```xml
     <uses-permission android:name="android.permission.INTERNET" />
     ```
     (en modo debug ya viene, pero en la versión release no).
   - Dentro del bloque `<queries>` que ya trae el archivo (si no existe, créalo
     antes de `<application>`), para que se pueda abrir el tráiler en Android 11+:
     ```xml
     <intent>
         <action android:name="android.intent.action.VIEW" />
         <data android:scheme="https" />
     </intent>
     ```
4. Descarga dependencias y ejecuta:
   ```
   flutter pub get
   ```
5. Crea tu archivo de clave. La clave de TheMovieDB **no está en el repositorio**:
   copia `secrets.example.json` como `secrets.json` y pon tu propia clave
   (se consigue gratis en https://www.themoviedb.org/settings/api):
   ```json
   {
     "TMDB_API_KEY": "tu_clave"
   }
   ```
   `secrets.json` está en el `.gitignore`, así que nunca se sube.
6. Ejecuta pasando el archivo de clave:
   ```
   flutter run --dart-define-from-file=secrets.json
   flutter run -d chrome --dart-define-from-file=secrets.json
   ```
   En VS Code o Android Studio, añade `--dart-define-from-file=secrets.json`
   a los argumentos de ejecución para no escribirlo cada vez.

Para comprobar el código sin emulador: `flutter analyze` y `flutter test`.

> La clave no está en el código fuente, pero sí queda dentro de la app compilada
> (en web se puede ver en el JavaScript). Para una clave de TheMovieDB es aceptable.

## Estructura

```
lib/
  main.dart                 App, tema y splash        (SplashActivity, styles.xml)
  config.dart               URL, clave API, colores   (colors.xml, constantes)
  textos.dart               Textos es/en              (values/strings.xml, values-es/)
  navegacion.dart           Abrir fichas              (Intent + putExtra + startActivity)
  models/modelos.dart       Película, Serie, Persona… (las ~30 clases de ui/models)
  services/tmdb_service.dart  Llamadas a la API       (TheMovieDBService + Retrofit)
  data/listas_db.dart       Favoritas y Quiero ver    (BaseDatosHandler)
  screens/
    inicio_screen.dart      Barra inferior            (MainActivity + BottomNavigationView)
    catalogo_screen.dart    Películas / Series        (PeliculasFragment y SeriesFragment)
    mis_listas_screen.dart  Mis listas                (FavoritosFragment)
    pelicula_screen.dart    Ficha de película         (PeliculaActivity)
    serie_screen.dart       Ficha de serie            (SerieActivity)
    actor_screen.dart       Ficha de actor            (ActorActivity)
  widgets/                  Tarjetas, barra inferior… (layouts de item + adaptadores)
```

## Equivalencias principales

| Android (Java)                                   | Flutter                                     |
|--------------------------------------------------|---------------------------------------------|
| Layouts XML + `findViewById`                     | Widgets construidos en `build()`            |
| `RecyclerView` + `Adapter` + `ViewHolder`        | `ListView.builder` / `ListView.separated`   |
| Retrofit + Gson + `enqueue(Callback)`            | `http` + `jsonDecode` + `async/await`       |
| `ProgressBar` + `onResponse`/`onFailure`         | `FutureBuilder` (widget `CargaFutura`)      |
| Picasso                                          | `Image.network`                             |
| `RatingBar`                                      | Widget `Estrellas`                          |
| `CircleImageView`                                | `ClipOval`                                  |
| `SQLiteOpenHelper`                               | paquete `sqflite`                           |
| `Intent` + `putExtra` / `finish()`               | `Navigator.push` con parámetro / `pop`      |
| `Intent.ACTION_VIEW` (YouTube)                   | paquete `url_launcher`                      |
| `TextWatcher`                                    | `TextField.onChanged`                       |
| `onResume()` del fragment de favoritos           | `ValueNotifier` en `ListasDb`: Mis listas se actualiza sola al cambiar algo |

## Secciones del inicio

- **Películas:** Destacadas (carrusel), Ahora en cines, Próximamente (con la
  fecha de estreno), Populares y Mejor valoradas.
- **Series:** Destacadas, En emisión esta semana, Populares y Mejor valoradas.

Los estrenos dependen del país del dispositivo (`Config.region`); si el
sistema no lo indica, se usa España en español y EE. UU. en el resto.

## Mis listas

- **Quiero ver**: lista de deseos. Se añade desde el botón «Quiero ver» de
  cualquier ficha. En la pantalla Mis listas, el botón ✓ («Ya la he visto»)
  la quita de la lista, con opción de deshacer.
- **Favoritas**: igual que en el original, con el botón del corazón.
- Las dos listas se pueden filtrar por películas o series y se ordenan de la
  más reciente a la más antigua.

La base de datos pasa a la **versión 2**: se añaden las tablas
`peliculas_por_ver` y `series_por_ver`, y una columna `anadido` (fecha) en
todas. Al actualizar, los favoritos que ya hubiera **se conservan**
(el `onUpgrade` del original borraba las tablas).

## Cambios respecto a la original

- **Películas del actor:** el original leía el campo `crew` (trabajos detrás de
  cámara) en vez de `cast`, así que a muchos actores no les salía ninguna
  película. Ahora se usa `cast`.
- **Estudio y género de las series:** el original mostraba solo el primero y la
  app se cerraba si la lista venía vacía. Ahora se muestran todos y no falla.
- **Búsqueda:** antes se lanzaba una petición por cada letra. Ahora espera
  400 ms desde la última tecla y descarta respuestas antiguas.
- **Base de datos:** la conexión se abre una vez y las consultas usan
  parámetros (`?`) en vez de concatenar el id en el SQL.
- **Errores de red:** si una carga falla aparece un mensaje con botón de
  reintentar (antes solo se escribía en el Log).
- PeliculasFragment y SeriesFragment eran casi iguales; ahora son una sola
  pantalla (`CatalogoScreen`) con un parámetro `esSeries`.
- Se añade una sección de **Reparto** con título en las fichas (antes la lista
  no tenía título).

## Logo

El logo es una entrada de cine con un botón de play (amarillo `#F3D767`
sobre azul `#0E1621`). El original vectorial está en
`assets/logo/logo_entrada.svg`; a partir de él se generan:

- `assets/images/logo.png`: pantalla de inicio (splash) de Flutter.
- Iconos de la app en `android/app/src/main/res/mipmap-*`,
  `ios/Runner/Assets.xcassets/AppIcon.appiconset` y `web/icons`, además de
  `web/favicon.png`.

La pantalla nativa que aparece antes de arrancar Flutter usa el mismo azul
(`android/app/src/main/res/values/colors.xml`).

## Publicar en Google Play

Identificador de la app: **`work.alcancia.peliculeitor`** (no se puede cambiar
una vez publicada).

1. **Clave de subida** (una sola vez). Créala y guárdala en lugar seguro:
   ```
   keytool -genkey -v -keystore %USERPROFILE%\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   Copia `android/key.properties.example` como `android/key.properties` y
   rellena las contraseñas y la ruta. `key.properties` y los `.jks` están en el
   `.gitignore`: nunca se suben. Sin `key.properties` la versión release se
   firma con la clave de depuración (sirve para probar, no para Google Play).
2. **Logo de TMDB.** Sus condiciones obligan a mostrar uno de sus logos
   oficiales en la sección de créditos. Descárgalo de
   https://www.themoviedb.org/about/logos-attribution y guárdalo como
   `assets/images/tmdb_logo.png`. La pantalla «Acerca de» (icono ⓘ del
   inicio) ya lo muestra junto al aviso obligatorio.
3. **Política de privacidad.** Rellena los corchetes de
   `docs/politica-privacidad.md` y súbelo. Su URL en GitHub es la que se
   pone en Play Console.
4. **Versión.** En cada subida, aumenta el número tras el `+` de
   `version:` en `pubspec.yaml` (`1.0.0+1` → `1.0.0+2`...).
5. **Generar el App Bundle:**
   ```
   flutter build appbundle --dart-define-from-file=secrets.json
   ```
   Resultado: `build/app/outputs/bundle/release/app-release.aab`.
6. **Play Console.** Textos de la ficha, icono de 512 px, imagen destacada y
   respuestas a los cuestionarios en `store/`.
