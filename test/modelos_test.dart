import 'package:flutter_test/flutter_test.dart';
import 'package:peliculeitor/models/modelos.dart';

void main() {
  test('Pelicula.fromJson lee los campos y calcula la valoración sobre 5', () {
    final p = Pelicula.fromJson({
      'id': 550,
      'title': 'El club de la lucha',
      'poster_path': '/abc.jpg',
      'vote_average': 8.4,
      'genres': [
        {'id': 18, 'name': 'Drama'}
      ],
      'production_companies': [
        {'id': 1, 'name': 'Fox 2000 Pictures'}
      ],
    });
    expect(p.id, 550);
    expect(p.titulo, 'El club de la lucha');
    expect(p.valoracion, closeTo(4.2, 0.001));
    expect(p.generos, ['Drama']);
    expect(p.estudios, ['Fox 2000 Pictures']);
  });

  test('Serie.fromJson tolera listas y campos que faltan', () {
    final s = Serie.fromJson({'id': 1, 'name': 'Serie', 'vote_average': 7});
    expect(s.cadenas, isEmpty);
    expect(s.generos, isEmpty);
    expect(s.temporadas, isNull);
    expect(s.comoElemento.esSerie, isTrue);
  });
}
