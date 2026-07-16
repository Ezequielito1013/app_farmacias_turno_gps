import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

/// Servicio responsable de comunicarse con el hardware GPS del dispositivo.
/// Sigue el principio de Responsabilidad Única (SRP).
class ServicioGps {
  /// Obtiene la posición actual del dispositivo luego de verificar permisos.
  Future<Position?> obtenerUbicacionActual() async {
    bool servicioHabilitado;
    LocationPermission permiso;

    // 1. Verificamos si el hardware GPS está encendido en el teléfono.
    servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      debugPrint('El servicio de ubicación está deshabilitado.');
      return null;
    }

    // 2. Revisamos el estado actual del permiso en Android.
    permiso = await Geolocator.checkPermission();
    
    // Si el permiso fue denegado previamente, lo volvemos a pedir.
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        debugPrint('Los permisos de ubicación fueron denegados.');
        return null;
      }
    }
    
    // Si el usuario marcó "No preguntar de nuevo" (denegado permanentemente).
    if (permiso == LocationPermission.deniedForever) {
      debugPrint('Los permisos de ubicación están denegados permanentemente.');
      return null;
    } 

    // 3. Obtenemos la posición con alta precisión, pero con un límite de tiempo.
    // Esto evita que la app se quede colgada infinitamente (especialmente en emuladores).
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low, // Cambiado a 'low' para funcionar súper rápido en interiores usando WiFi/Antenas
          timeLimit: Duration(seconds: 15), // Damos un poco más de margen
        ),
      );
    } catch (e) {
      debugPrint('Timeout al buscar GPS actual. Intentando última posición conocida...');
      // Fallback: Si tarda mucho, usar la última ubicación guardada en caché.
      final ultimaPosicion = await Geolocator.getLastKnownPosition();
      if (ultimaPosicion != null) {
        return ultimaPosicion;
      }
      return null;
    }
  }
}
