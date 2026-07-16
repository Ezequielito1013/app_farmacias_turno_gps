import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_farmacias_turno_gps/features/clima/widgets/widget_clima.dart';
import 'package:app_farmacias_turno_gps/features/clima/proveedores/proveedor_clima.dart';


void main() {
  testWidgets('WidgetClima muestra "Fuera de cobertura UTEM" cuando el provider falla con un 404', (WidgetTester tester) async {
    // 1. Arrange: Preparamos la ubicación de prueba (Rancagua)
    const ubicacionPrueba = LatLng(-34.0543946, -70.5743791);

    // Sobrescribimos el climaProvider para que simule el error 404 de la API
    final provedorSobrescrito = climaProvider(ubicacionPrueba).overrideWith((ref) {
      return Future.error(Exception('Error al contactar con la API: 404 Not Found'));
    });

    // Construimos la UI
    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSobrescrito],
        child: const MaterialApp(
          home: Scaffold(
            body: WidgetClima(ubicacion: ubicacionPrueba),
          ),
        ),
      ),
    );

    // Al principio debería mostrar "Consultando clima..."
    expect(find.text('Consultando clima...'), findsOneWidget);

    // 2. Act: Esperamos a que se resuelva el Future (el error)
    await tester.pumpAndSettle();

    // 3. Assert: Verificamos que se muestre el texto de fuera de cobertura
    expect(find.text('Fuera de cobertura UTEM'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
  });

  testWidgets('WidgetClima muestra "Clima no disponible" ante otros errores', (WidgetTester tester) async {
    const ubicacionPrueba = LatLng(-34.0, -70.0);

    final provedorSobrescrito = climaProvider(ubicacionPrueba).overrideWith((ref) {
      return Future.error(Exception('Error de conexión a internet (SocketException)'));
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSobrescrito],
        child: const MaterialApp(
          home: Scaffold(
            body: WidgetClima(ubicacion: ubicacionPrueba),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Clima no disponible'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
  });
}
