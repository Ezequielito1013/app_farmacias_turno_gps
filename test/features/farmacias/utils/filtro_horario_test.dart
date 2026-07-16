import 'package:flutter_test/flutter_test.dart';
import 'package:app_farmacias_turno_gps/features/farmacias/utils/filtro_horario.dart';

void main() {
  group('FiltroHorario', () {
    final juevesNormal = DateTime(2026, 7, 16, 12, 0); // Jueves 12:00
    
    test('Farmacia sin horario es descartada', () {
      expect(FiltroHorario.estaAbiertaYEnDia(null, null, 'jueves', juevesNormal), false);
      expect(FiltroHorario.estaAbiertaYEnDia('', '', 'jueves', juevesNormal), false);
    });

    test('Horario normal (08:30 a 22:00)', () {
      const apertura = '08:30:00';
      const cierre = '22:00:00';
      
      // Antes de abrir
      expect(FiltroHorario.estaAbiertaYEnDia(apertura, cierre, 'jueves', DateTime(2026, 7, 16, 8, 29)), false);
      
      // Exactamente al abrir
      expect(FiltroHorario.estaAbiertaYEnDia(apertura, cierre, 'jueves', DateTime(2026, 7, 16, 8, 30)), true);
      
      // Medio día (abierto)
      expect(FiltroHorario.estaAbiertaYEnDia(apertura, cierre, 'jueves', DateTime(2026, 7, 16, 14, 0)), true);
      
      // Exactamente al cerrar
      expect(FiltroHorario.estaAbiertaYEnDia(apertura, cierre, 'jueves', DateTime(2026, 7, 16, 22, 0)), true);
      
      // Después de cerrar
      expect(FiltroHorario.estaAbiertaYEnDia(apertura, cierre, 'jueves', DateTime(2026, 7, 16, 22, 01)), false);
    });

    test('Horario que cruza la medianoche (09:00 a 08:59)', () {
      const apertura = '09:00:00';
      const cierre = '08:59:00';
      
      // Madrugada (está abierta del turno que empezó el miércoles)
      expect(FiltroHorario.estaAbiertaYEnDia(apertura, cierre, 'miércoles', DateTime(2026, 7, 16, 2, 0)), true); // 16 es Jueves, turno de ayer (miércoles)
      
      // Madrugada (falla si el día reportado es hoy porque es turno de ayer)
      expect(FiltroHorario.estaAbiertaYEnDia(apertura, cierre, 'jueves', DateTime(2026, 7, 16, 2, 0)), false);
      
      // Minuto antes de cerrar (turno del miércoles)
      expect(FiltroHorario.estaAbiertaYEnDia(apertura, cierre, 'miércoles', DateTime(2026, 7, 16, 8, 58)), true);
      
      // Abriendo nuevamente (turno del jueves)
      expect(FiltroHorario.estaAbiertaYEnDia(apertura, cierre, 'jueves', DateTime(2026, 7, 16, 9, 0)), true);
    });

    test('Farmacia 24 horas (00:00 a 00:00)', () {
      const apertura = '00:00:00';
      const cierre = '00:00:00';
      
      expect(FiltroHorario.estaAbiertaYEnDia(apertura, cierre, 'jueves', DateTime(2026, 7, 16, 0, 0)), true);
      expect(FiltroHorario.estaAbiertaYEnDia(apertura, cierre, 'jueves', DateTime(2026, 7, 16, 12, 0)), true);
      expect(FiltroHorario.estaAbiertaYEnDia(apertura, cierre, 'jueves', DateTime(2026, 7, 16, 23, 59)), true);
      
      // No coincide el día
      expect(FiltroHorario.estaAbiertaYEnDia(apertura, cierre, 'viernes', DateTime(2026, 7, 16, 12, 0)), false);
    });

    test('Farmacia 24 horas con horario idéntico no-medianoche (08:00 a 08:00)', () {
      const apertura = '08:00:00';
      const cierre = '08:00:00';
      
      // Debe ser tratada como 24 horas y siempre estar abierta si el día coincide
      expect(FiltroHorario.estaAbiertaYEnDia(apertura, cierre, 'jueves', DateTime(2026, 7, 16, 4, 0)), true);
      expect(FiltroHorario.estaAbiertaYEnDia(apertura, cierre, 'jueves', DateTime(2026, 7, 16, 12, 0)), true);
      expect(FiltroHorario.estaAbiertaYEnDia(apertura, cierre, 'jueves', DateTime(2026, 7, 16, 23, 59)), true);
    });
  });
}
