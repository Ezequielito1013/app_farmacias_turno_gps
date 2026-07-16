import 'package:flutter/material.dart';
import '../widgets/boton_google.dart';

/// Pantalla visual de Login. 
/// Es Stateless porque la lógica y el estado de carga ahora los maneja 
/// directamente el Riverpod Provider dentro del widget BotonGoogle.
class PantallaLogin extends StatelessWidget {
  const PantallaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Fondo limpio
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono genérico (cumpliendo diseño estándar)
              const Icon(
                Icons.local_pharmacy,
                size: 80,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 24),
              const Text(
                'Farmacias de Turno',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Inicia sesión para descubrir las\nfarmacias operativas cerca de ti.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 48),
              
              // Widget modularizado (Responsabilidad Única).
              // Ya no necesitamos pasarle parámetros, el botón es inteligente
              // y se conecta solo al servicio de Riverpod.
              const BotonGoogle(),
            ],
          ),
        ),
      ),
    );
  }
}
