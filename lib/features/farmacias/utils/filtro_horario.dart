import 'package:flutter/material.dart';

class FiltroHorario {
  /// Convierte un String (ej. "08:30:00") a TimeOfDay
  static TimeOfDay? parsearHora(String? horaStr) {
    if (horaStr == null || horaStr.isEmpty) return null;
    final partes = horaStr.split(':');
    if (partes.length >= 2) {
      return TimeOfDay(
        hour: int.tryParse(partes[0]) ?? 0,
        minute: int.tryParse(partes[1]) ?? 0,
      );
    }
    return null;
  }

  /// Convierte TimeOfDay a minutos totales
  static int _aMinutos(TimeOfDay t) => t.hour * 60 + t.minute;

  static String _normalizarDia(String dia) {
    return dia.toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }

  static String _obtenerNombreDia(DateTime fecha) {
    const dias = ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'];
    return dias[fecha.weekday - 1];
  }

  /// Verifica si la hora actual está dentro del horario y si corresponde al día de funcionamiento
  static bool estaAbiertaYEnDia(String? apertura, String? cierre, String? diaFuncionamiento, DateTime ahora) {
    final tApertura = parsearHora(apertura);
    final tCierre = parsearHora(cierre);

    if (tApertura == null || tCierre == null) {
      return false; // Farmacias sin horario válido se descartan
    }

    final minApertura = _aMinutos(tApertura);
    final minCierre = _aMinutos(tCierre);
    final minAhora = _aMinutos(TimeOfDay.fromDateTime(ahora));

    bool cruzaMedianoche = minApertura >= minCierre && (minApertura != 0 || minCierre != 0);
    bool es24Horas = (minApertura == 0 && minCierre == 0) || (minApertura == minCierre);

    bool abiertaPorHora = false;
    bool esTurnoAnterior = false; 

    if (es24Horas) {
      abiertaPorHora = true;
    } else if (!cruzaMedianoche) {
      abiertaPorHora = minAhora >= minApertura && minAhora <= minCierre;
    } else {
      if (minAhora >= minApertura) {
        abiertaPorHora = true;
      } else if (minAhora <= minCierre) {
        abiertaPorHora = true;
        esTurnoAnterior = true; // Estamos en la madrugada del día siguiente al inicio del turno
      }
    }

    if (!abiertaPorHora) return false;

    // Si no trae día, asumimos que es correcto (ej. API UTEM)
    if (diaFuncionamiento == null || diaFuncionamiento.isEmpty) return true;

    final diaNormalizado = _normalizarDia(diaFuncionamiento);
    
    // Ajustar el día lógico si estamos en la madrugada de un turno cruzado
    DateTime fechaLogica = ahora;
    if (esTurnoAnterior) {
      fechaLogica = ahora.subtract(const Duration(days: 1));
    }

    final diaActualNormalizado = _obtenerNombreDia(fechaLogica);
    return diaNormalizado == diaActualNormalizado;
  }
}
