import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Sustituye a BaseDatosHandler (SQLiteOpenHelper).
/// Misma base de datos ("peliculeitor") y mismas tablas: peliculas(id) y series(id).
class FavoritosDb {
  FavoritosDb._();
  static final FavoritosDb instancia = FavoritosDb._();

  static const _tablaPeliculas = 'peliculas';
  static const _tablaSeries = 'series';

  Database? _db;

  /// Abre la base de datos la primera vez y reutiliza la conexión después.
  /// (En el original se abría y cerraba en cada método.)
  Future<Database> get _database async {
    if (_db != null) return _db!;
    final ruta = join(await getDatabasesPath(), 'peliculeitor');
    _db = await openDatabase(
      ruta,
      version: 1,
      // equivale a onCreate()
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE IF NOT EXISTS $_tablaPeliculas (id INTEGER PRIMARY KEY)');
        await db.execute('CREATE TABLE IF NOT EXISTS $_tablaSeries (id INTEGER PRIMARY KEY)');
      },
      // equivale a onUpgrade()
      onUpgrade: (db, anterior, nueva) async {
        await db.execute('DROP TABLE IF EXISTS $_tablaPeliculas');
        await db.execute('DROP TABLE IF EXISTS $_tablaSeries');
        await db.execute('CREATE TABLE $_tablaPeliculas (id INTEGER PRIMARY KEY)');
        await db.execute('CREATE TABLE $_tablaSeries (id INTEGER PRIMARY KEY)');
      },
    );
    return _db!;
  }

  // ---------- Read ----------
  Future<List<int>> idsPeliculas() => _ids(_tablaPeliculas);
  Future<List<int>> idsSeries() => _ids(_tablaSeries);

  Future<List<int>> _ids(String tabla) async {
    final filas = await (await _database).query(tabla);
    return filas.map((f) => f['id'] as int).toList();
  }

  Future<bool> esPeliculaFavorita(int id) => _existe(_tablaPeliculas, id);
  Future<bool> esSerieFavorita(int id) => _existe(_tablaSeries, id);

  Future<bool> _existe(String tabla, int id) async {
    // Consulta con parámetro (?) en vez de concatenar el id en el SQL.
    final filas = await (await _database).query(tabla, where: 'id = ?', whereArgs: [id]);
    return filas.isNotEmpty;
  }

  // ---------- Create ----------
  Future<void> agregarPelicula(int id) => _insertar(_tablaPeliculas, id);
  Future<void> agregarSerie(int id) => _insertar(_tablaSeries, id);

  Future<void> _insertar(String tabla, int id) async {
    await (await _database)
        .insert(tabla, {'id': id}, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // ---------- Delete ----------
  Future<void> borrarPelicula(int id) => _borrar(_tablaPeliculas, id);
  Future<void> borrarSerie(int id) => _borrar(_tablaSeries, id);

  Future<void> _borrar(String tabla, int id) async {
    await (await _database).delete(tabla, where: 'id = ?', whereArgs: [id]);
  }
}
