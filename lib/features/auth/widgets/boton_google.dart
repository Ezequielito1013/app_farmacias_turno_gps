import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../proveedores/proveedor_auth.dart';

class BotonGoogle extends ConsumerStatefulWidget {
  const BotonGoogle({super.key});

  @override
  ConsumerState<BotonGoogle> createState() => _BotonGoogleState();
}

class _BotonGoogleState extends ConsumerState<BotonGoogle> {
  bool _cargandoLocal = false;

  @override
  Widget build(BuildContext context) {
    // Mantenemos la lógica global por si ya viene cargando de entrada
    final estadoAuth = ref.watch(estadoAuthStateProvider);
    final bool estaCargando = estadoAuth.isLoading || _cargandoLocal;

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
                setState(() {
                  _cargandoLocal = true;
                });
                try {
                  // Ejecutamos la función de login del servicio
                  await ref.read(servicioAuthProvider).iniciarSesionConGoogle();
                } catch (e) {
                  // Si ocurre un error o el usuario cancela, detenemos el estado de carga
                  if (mounted) {
                    setState(() {
                      _cargandoLocal = false;
                    });
                  }
                }
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
