import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Las dos listas personales que guarda la app.
enum Lista { favoritos, porVer }

/// Una fila de una lista: qué película o serie es y cuándo se añadió.
class EntradaLista {
  final int id;
  final bool esSerie;
  final int anadido; // milisegundos desde 1970

  const EntradaLista({required this.id, required this.esSerie, required this.anadido});
}

/// Base de datos local con las listas del usuario. Sustituye a FavoritosDb
/// (y al BaseDatosHandler del original), añadiendo la lista "Quiero ver".
///
/// Tablas (versión 2):
///   peliculas, series                    -> favoritos (las del proyecto original)
///   peliculas_por_ver, series_por_ver     -> lista de deseos
/// Todas tienen: id INTEGER PRIMARY KEY, anadido INTEGER (fecha en que se añadió).
class ListasDb {
  ListasDb._();
  static final ListasDb instancia = ListasDb._();

  static const _version = 2;

  /// Cambia cada vez que se añade o quita algo de cualquier lista.
  /// Las pantallas lo escuchan para refrescarse solas (ValueListenableBuilder
  /// o addListener), sin tener que recargar a mano al volver de una ficha.
  final ValueNotifier<int> cambios = ValueNotifier<int>(0);

  Database? _db;

  static String _tabla(Lista lista, bool esSerie) {
    if (lista == Lista.favoritos) return esSerie ? 'series' : 'peliculas';
    return esSerie ? 'series_por_ver' : 'peliculas_por_ver';
  }

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final ruta = join(await getDatabasesPath(), 'peliculeitor');
    _db = await openDatabase(
      ruta,
      version: _version,
      onCreate: (db, version) async {
        for (final tabla in ['peliculas', 'series', 'peliculas_por_ver', 'series_por_ver']) {
          await db.execute(
              'CREATE TABLE $tabla (id INTEGER PRIMARY KEY, anadido INTEGER NOT NULL DEFAULT 0)');
        }
      },
      // Migración desde la versión 1 (solo favoritos, sin fecha).
      // A diferencia del original, NO se borran las tablas: se conservan los
      // favoritos que ya tuviera el usuario.
      onUpgrade: (db, anterior, nueva) async {
        if (anterior < 2) {
          await db.execute(
              'ALTER TABLE peliculas ADD COLUMN anadido INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE series ADD COLUMN anadido INTEGER NOT NULL DEFAULT 0');
          await db.execute(
              'CREATE TABLE IF NOT EXISTS peliculas_por_ver (id INTEGER PRIMARY KEY, anadido INTEGER NOT NULL DEFAULT 0)');
          await db.execute(
              'CREATE TABLE IF NOT EXISTS series_por_ver (id INTEGER PRIMARY KEY, anadido INTEGER NOT NULL DEFAULT 0)');
        }
      },
    );
    return _db!;
  }

  /// Películas y series de una lista, de la más reciente a la más antigua.
  Future<List<EntradaLista>> entradas(Lista lista) async {
    final db = await _database;
    final resultado = <EntradaLista>[];
    for (final esSerie in [false, true]) {
      final filas = await db.query(_tabla(lista, esSerie));
      resultado.addAll(filas.map((f) => EntradaLista(
            id: f['id'] as int,
            esSerie: esSerie,
            anadido: (f['anadido'] as int?) ?? 0,
          )));
    }
    resultado.sort((a, b) => b.anadido.compareTo(a.anadido));
    return resultado;
  }

  Future<bool> contiene(Lista lista, {required int id, required bool esSerie}) async {
    final filas = await (await _database)
        .query(_tabla(lista, esSerie), where: 'id = ?', whereArgs: [id]);
    return filas.isNotEmpty;
  }

  Future<void> agregar(Lista lista, {required int id, required bool esSerie}) async {
    await (await _database).insert(
      _tabla(lista, esSerie),
      {'id': id, 'anadido': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    cambios.value++;
  }

  Future<void> quitar(Lista lista, {required int id, required bool esSerie}) async {
    await (await _database)
        .delete(_tabla(lista, esSerie), where: 'id = ?', whereArgs: [id]);
    cambios.value++;
  }
}
