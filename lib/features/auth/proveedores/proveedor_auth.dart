import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../servicios/servicio_auth.dart';

/// 1. Proveedor global del servicio de autenticación
/// Mantiene viva la instancia de ServicioAuth en toda la app.
final servicioAuthProvider = Provider<ServicioAuth>((ref) {
  return ServicioAuth();
});

/// 2. Proveedor que escucha el stream de sesión de Firebase
/// Este StreamProvider emitirá un valor automáticamente (y redibujará la UI)
/// cada vez que el usuario inicie sesión, cierre sesión o expire su token.
final estadoAuthStateProvider = StreamProvider<User?>((ref) {
  final servicio = ref.watch(servicioAuthProvider);
  return servicio.obtenerEstadoAutenticacion();
});
