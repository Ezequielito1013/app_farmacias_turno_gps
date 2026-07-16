import 'package:flutter_test/flutter_test.dart';
import 'package:app_farmacias_turno_gps/features/farmacias/modelos/modelo_farmacia.dart';

void main() {
  group('ModeloFarmacia', () {
    test('fromJsonMinsal mapea correctamente un payload completo', () {
      final json = {
        "local_nombre": "CRUZ VERDE",
        "local_direccion": "URMENETA 99",
        "funcionamiento_hora_apertura": "08:30:00",
        "funcionamiento_hora_cierre": "18:30:00",
        "local_lat": "-32.984992",
        "local_lng": "-71.275717",
        "local_telefono": "+56912345678",
        "funcionamiento_dia": "jueves"
      };

      final farmacia = ModeloFarmacia.fromJsonMinsal(json);

      expect(farmacia.nombre, 'CRUZ VERDE');
      expect(farmacia.direccion, 'URMENETA 99');
      expect(farmacia.latitud, -32.984992);
      expect(farmacia.longitud, -71.275717);
      expect(farmacia.telefono, '+56912345678');
      expect(farmacia.apertura, '08:30:00');
      expect(farmacia.cierre, '18:30:00');
      expect(farmacia.dia, 'jueves');
    });

    test('fromJsonUtem mapea correctamente un payload de UTEM', () {
      final json = {
        "apertura_normal": "00:00:00",
        "cierre_normal": "00:00:00",
        "direccion": "CERRO NAVIA",
        "latitude": -33.417333,
        "longitude": -70.747545,
        "nombre": "SALVADOR GUTIERREZ",
        "telefono": "22123456"
      };

      final farmacia = ModeloFarmacia.fromJsonUtem(json);

      expect(farmacia.nombre, 'SALVADOR GUTIERREZ');
      expect(farmacia.direccion, 'CERRO NAVIA');
      expect(farmacia.latitud, -33.417333);
      expect(farmacia.longitud, -70.747545);
      expect(farmacia.telefono, '22123456');
      expect(farmacia.apertura, '00:00:00');
      expect(farmacia.cierre, '00:00:00');
      expect(farmacia.dia, null); // UTEM no tiene este campo
    });

    test('Maneja campos nulos con valores por defecto', () {
      final farmacia = ModeloFarmacia.fromJsonMinsal({});

      expect(farmacia.nombre, 'Farmacia MINSAL');
      expect(farmacia.latitud, 0.0);
      expect(farmacia.longitud, 0.0);
      expect(farmacia.telefono, '');
      expect(farmacia.apertura, null);
      expect(farmacia.cierre, null);
      expect(farmacia.dia, null);
    });
  });
}
