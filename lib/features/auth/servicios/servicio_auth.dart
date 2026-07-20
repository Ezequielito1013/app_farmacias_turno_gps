import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../modelos/usuario_modelo.dart';

/// Servicio encargado de orquestar la comunicación con Firebase y Google (Principio de Responsabilidad Única).
class ServicioAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // Añadir explícitamente el Web Client ID extraído desde el archivo .env (Buenas prácticas / DevOps)
  // Esto obliga a Google a devolver un idToken en Release mode sin amarrar el código fuente al Firebase personal.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: dotenv.env['WEB_CLIENT_ID'],
  );

  /// Instancia global de Google SignIn para poder reutilizarla en el Interceptor (evita errores en Release)
  GoogleSignIn get googleSignIn => _googleSignIn;

  /// Flujo principal para iniciar sesión con Google
  Future<UsuarioModelo?> iniciarSesionConGoogle() async {
    try {
      // 1. Desplegar el modal nativo de Google Sign-In
      final GoogleSignInAccount? cuentaGoogle = await _googleSignIn.signIn();
      if (cuentaGoogle == null) {
        // El usuario cerró el modal o canceló el proceso
        return null;
      }

      // 2. Obtener los tokens de autenticación desde la cuenta seleccionada
      final GoogleSignInAuthentication googleAuth = await cuentaGoogle.authentication;

      // 3. Empaquetar los tokens en una credencial que Firebase entienda
      final AuthCredential credencial = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Iniciar sesión en Firebase de forma segura usando la credencial
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credencial);
      final User? usuarioFirebase = userCredential.user;

      // 5. Si fue exitoso, mapeamos el usuario de Firebase a nuestro propio modelo
      if (usuarioFirebase != null) {
        return UsuarioModelo(
          id: usuarioFirebase.uid,
          nombre: usuarioFirebase.displayName ?? 'Usuario Sin Nombre',
          correo: usuarioFirebase.email ?? 'sin-correo@example.com',
          urlFoto: usuarioFirebase.photoURL,
        );
      }
      return null;
    } catch (e) {
      // En una app de producción esto iría a un servicio de Logs (Crashlytics)
      debugPrint('=== ERROR EN GOOGLE SIGN-IN ===\n$e');
      return null;
    }
  }

  /// Cerrar Sesión tanto en Google como en Firebase
  Future<void> cerrarSesion() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  /// Exponer el estado reactivo de la sesión de Firebase para que Riverpod lo escuche
  Stream<User?> obtenerEstadoAutenticacion() {
    return _firebaseAuth.authStateChanges();
  }
}
