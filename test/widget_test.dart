import 'package:flutter_test/flutter_test.dart';
import 'package:asana_check/main.dart'; // O el nombre de tu proyecto

void main() {
  testWidgets('Prueba básica de carga de la app', (WidgetTester tester) async {
    // Iniciamos la app con el nombre correcto de tu widget
    await tester.pumpWidget(const AsanaCheckApp());

    // Verificamos que al menos cargue el texto de bienvenida
    expect(find.text('Namasté, Yogui'), findsOneWidget);
  });
}