import 'package:flutter_test/flutter_test.dart';
import 'package:peliculeitor/models/modelos.dart';
import 'package:peliculeitor/widgets/ficha_detalle.dart';

void main() {
  test('Pelicula.fromJson lee los campos principales', () {
    final p = Pelicula.fromJson({
      'id': 550,
      'title': 'El club de la lucha',
      'poster_path': '/abc.jpg',
      'backdrop_path': '/fondo.jpg',
      'vote_average': 8.4,
      'vote_count': 30000,
      'release_date': '1999-10-15',
      'runtime': 139,
      'genres': [
        {'id': 18, 'name': 'Drama'}
      ],
      'production_companies': [
        {'id': 1, 'name': 'Fox 2000 Pictures'}
      ],
    });
    expect(p.id, 550);
    expect(p.titulo, 'El club de la lucha');
    expect(p.votoMedio, closeTo(8.4, 0.001));
    expect(p.duracion, 139);
    expect(p.generos, ['Drama']);
    expect(p.estudios, ['Fox 2000 Pictures']);
    expect(p.comoElemento.anio, '1999');
    expect(p.comoElemento.fondo, '/fondo.jpg');
  });

  test('Serie.fromJson tolera listas y campos que faltan', () {
    final s = Serie.fromJson({'id': 1, 'name': 'Serie', 'vote_average': 7});
    expect(s.cadenas, isEmpty);
    expect(s.generos, isEmpty);
    expect(s.temporadas, isNull);
    expect(s.comoElemento.esSerie, isTrue);
    expect(s.comoElemento.anio, '');
  });

  test('formatoDuracion', () {
    expect(formatoDuracion(139), '2 h 19 min');
    expect(formatoDuracion(120), '2 h');
    expect(formatoDuracion(45), '45 min');
    expect(formatoDuracion(null), '');
  });
}
