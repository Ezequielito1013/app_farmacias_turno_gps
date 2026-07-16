import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_farmacias_turno_gps/features/farmacias/modelos/modelo_farmacia.dart';
import 'package:app_farmacias_turno_gps/features/farmacias/proveedores/proveedor_farmacias.dart';

void main() {
  group('FarmaciaSeleccionadaNotifier', () {
    test('El estado inicial es null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final seleccionada = container.read(farmaciaSeleccionadaProvider);
      expect(seleccionada, isNull);
    });

    test('seleccionar() actualiza el estado con la farmacia provista', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final farmacia = ModeloFarmacia(
        nombre: 'Farmacia de Prueba',
        direccion: 'Calle Falsa 123',
        latitud: 0.0,
        longitud: 0.0,
      );

      container.read(farmaciaSeleccionadaProvider.notifier).seleccionar(farmacia);
      
      final seleccionada = container.read(farmaciaSeleccionadaProvider);
      expect(seleccionada?.nombre, 'Farmacia de Prueba');
    });

    test('limpiar() vuelve el estado a null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final farmacia = ModeloFarmacia(
        nombre: 'Farmacia 2',
        direccion: 'Av Test',
        latitud: 0.0,
        longitud: 0.0,
      );

      // Act
      container.read(farmaciaSeleccionadaProvider.notifier).seleccionar(farmacia);
      container.read(farmaciaSeleccionadaProvider.notifier).limpiar();
      
      // Assert
      final seleccionada = container.read(farmaciaSeleccionadaProvider);
      expect(seleccionada, isNull);
    });
  });
}
