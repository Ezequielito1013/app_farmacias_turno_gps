import 'package:flutter/material.dart';

/// Widget de marcador estético y animado (efecto pulso/radar) para resaltar
/// fuertemente la farmacia destacada de la UTEM en el mapa.
class MarcadorDestacado extends StatefulWidget {
  const MarcadorDestacado({super.key});

  @override
  State<MarcadorDestacado> createState() => _MarcadorDestacadoState();
}

class _MarcadorDestacadoState extends State<MarcadorDestacado>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Controlador de la animación cíclica (efecto pulso continuo)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(); // Repetir infinitamente mientras el marcador exista

    // La escala crece de la mitad al doble de su tamaño base
    _scaleAnimation = Tween<double>(begin: 0.5, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // La opacidad va disminuyendo de visible a transparente a medida que crece
    _fadeAnimation = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Siempre limpiar controladores al destruir el widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // 1. Círculo trasero animado (Efecto Radar)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  width: 40, // Base sobre la cual aplica la escala (llegará hasta 80)
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            );
          },
        ),

        // 2. Marcador principal frontal estático (Diseño Premium)
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
            // Borde blanco grueso que le da un toque moderno y lo separa del fondo
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 8,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: const Icon(
            Icons.local_pharmacy, // Ícono específico de farmacia
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }
}
