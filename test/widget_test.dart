import 'package:flutter_test/flutter_test.dart';
import 'package:peliculeitor/main.dart';
import 'package:peliculeitor/screens/inicio_screen.dart';

void main() {
  testWidgets('Arranca con el splash y pasa al inicio', (tester) async {
    await tester.pumpWidget(const PeliculeitorApp());
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 1)); // salta el temporizador del splash
    await tester.pump(const Duration(milliseconds: 500)); // termina el fundido
    expect(find.byType(InicioScreen), findsOneWidget);
  });
}
