import 'dart:ui';

import 'package:flutter/material.dart';

/// Configuración general (antes repartida entre TheMovieDBService y cada Activity).
class Config {

  /// Clave de TheMovieDB. NO está en el código: se lee de secrets.json al compilar
  ///   flutter run --dart-define-from-file=secrets.json
  static const String apiKey = String.fromEnvironment('TMDB_API_KEY');

  static const String baseUrl = 'https://api.themoviedb.org/3/';
  static const String urlImagenes = 'https://image.tmdb.org/t/p/w500';

  /// Idioma del dispositivo ("es", "en"...). Equivale a
  /// getResources().getConfiguration().locale.getLanguage()
  static String get idioma => PlatformDispatcher.instance.locale.languageCode;

  /// Construye la URL completa de una imagen o null si no hay ruta.
  static String? imagen(String? ruta) =>
      (ruta == null || ruta.isEmpty) ? null : '$urlImagenes$ruta';
}

/// Colores sacados de los layouts XML y de colors.xml.
class Colores {
  static const fondo = Color(0xFF2A3849);
  static const fondoOscuro = Color(0xFF223951);
  static const texto = Color(0xFFEBEBEB);
  static const primario = Color(0xFFF3D767);
  static const estrellas = Color(0xFFFFD506);
  static const busqueda = Color(0xFF8DBDE0);
  static const boton = Color(0xFF5CA0D3);
}
