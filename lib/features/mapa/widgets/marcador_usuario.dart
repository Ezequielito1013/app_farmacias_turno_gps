import 'package:flutter/material.dart';

/// Diseño premium para el marcador de la ubicación actual del usuario.
/// Reemplaza el ícono genérico por el clásico punto azul vibrante 
/// con borde blanco y un pequeño halo, simulando precisión de GPS nativo.
class MarcadorUsuario extends StatelessWidget {
  const MarcadorUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8), // Espacio para el halo (círculo interior + padding = halo)
        decoration: BoxDecoration(
          color: Colors.blueAccent.withValues(alpha: 0.15), // Halo azul muy suave
          shape: BoxShape.circle,
        ),
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.blueAccent, // Punto central vivo
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white, 
              width: 3.5, // Borde blanco grueso para máximo contraste
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
