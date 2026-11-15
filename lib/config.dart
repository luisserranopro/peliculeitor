import 'dart:ui';

import 'package:flutter/material.dart';

/// Configuración general (antes repartida entre TheMovieDBService y cada Activity).
class Config {
  /// Clave de TheMovieDB. NO está en el código: se lee de secrets.json al compilar
  ///   flutter run --dart-define-from-file=secrets.json
  static const String apiKey = String.fromEnvironment('TMDB_API_KEY');

  static const String baseUrl = 'https://api.themoviedb.org/3/';
  static const String _urlImagenes = 'https://image.tmdb.org/t/p/';

  /// Idioma del dispositivo ("es", "en"...). Equivale a
  /// getResources().getConfiguration().locale.getLanguage()
  static String get idioma => PlatformDispatcher.instance.locale.languageCode;

  /// País del dispositivo ("ES", "MX"...). Los estrenos cambian según el país.
  /// Si el sistema no lo indica, se usa España para español y EE. UU. para el resto.
  static String get region {
    final pais = PlatformDispatcher.instance.locale.countryCode;
    if (pais != null && pais.isNotEmpty) return pais.toUpperCase();
    return idioma == 'es' ? 'ES' : 'US';
  }

  /// URL de un póster o foto (ancho 500) o null si no hay ruta.
  static String? imagen(String? ruta) =>
      (ruta == null || ruta.isEmpty) ? null : '${_urlImagenes}w500$ruta';

  /// URL de una imagen de fondo horizontal (ancho 1280) o null si no hay ruta.
  static String? imagenFondo(String? ruta) =>
      (ruta == null || ruta.isEmpty) ? null : '${_urlImagenes}w1280$ruta';
}

/// Paleta de la app. Mantiene el azul marino y el amarillo del original,
/// pero más oscura y con más contraste.
class Colores {
  static const fondo = Color(0xFF0E1621);
  static const superficie = Color(0xFF172232);
  static const superficieAlta = Color(0xFF223047);
  static const texto = Color(0xFFEDEFF2);
  static const textoSecundario = Color(0xFF94A3B8);
  static const acento = Color(0xFFF3D767); // colorPrimary del original
  static const azul = Color(0xFF5CA0D3); // botón del original
  static const favorito = Color(0xFFFF5A6E);
}

/// Espaciados y radios comunes, para que todas las pantallas encajen.
class Medidas {
  static const margen = 20.0;
  static const radio = 16.0;

  /// Hueco al final de las listas para que la barra inferior flotante
  /// no tape el último elemento.
  static const huecoBarra = 110.0;
}
