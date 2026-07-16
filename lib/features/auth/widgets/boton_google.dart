import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../proveedores/proveedor_auth.dart';

class BotonGoogle extends ConsumerWidget {
  const BotonGoogle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos el estado global de autenticación para saber si hay una carga en curso
    final estadoAuth = ref.watch(estadoAuthStateProvider);
    final bool estaCargando = estadoAuth.isLoading;

    return SizedBox(
      width: double.infinity,
      height: 50, // Altura estándar y cómoda para el dedo en móviles
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade400, width: 1), // Borde gris claro clásico
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Bordes ligeramente redondeados
          ),
          elevation: 1, // Sombra sutil para dar sensación de botón premium
        ),
        onPressed: estaCargando
            ? null // Si está procesando el login, el botón se deshabilita
            : () async {
                // Ejecutamos la función de login del servicio
                await ref.read(servicioAuthProvider).iniciarSesionConGoogle();
              },
        child: estaCargando
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.blueAccent,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cargamos el logo de Google desde nuestros assets locales
                  Image.asset(
                    'assets/images/google_logo.png',
                    height: 24,
                    width: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Iniciar sesión con Google',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
