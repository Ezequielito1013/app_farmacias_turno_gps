import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../servicios/servicio_gps.dart';

/// Proveedor para instanciar el ServicioGps de forma global
final servicioGpsProvider = Provider<ServicioGps>((ref) {
  return ServicioGps();
});

/// FutureProvider que obtiene la ubicación actual del dispositivo.
/// Al ser un FutureProvider, maneja automáticamente los estados de:
/// - loading (cargando)
/// - data (éxito, contiene la Position)
/// - error (falló por permisos o GPS apagado)
final ubicacionUsuarioProvider = FutureProvider<Position?>((ref) async {
  final servicioGps = ref.read(servicioGpsProvider);
  return await servicioGps.obtenerUbicacionActual();
});
