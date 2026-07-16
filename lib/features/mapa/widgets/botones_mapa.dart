import 'package:flutter/material.dart';

/// Conjunto de botones flotantes de acción para el mapa.
/// Extrae la lógica visual de los botones laterales (FABs) y el botón 
/// principal inferior, permitiendo inyectar sus acciones mediante callbacks.
class BotonesMapa extends StatelessWidget {
  final VoidCallback onCentrarUsuario;
  final VoidCallback onCentrarFarmacia;
  final VoidCallback onBuscarFarmacia;
  final bool isLoadingBuscando;
  final bool tieneFarmaciaDestacada;

  const BotonesMapa({
    super.key,
    required this.onCentrarUsuario,
    required this.onCentrarFarmacia,
    required this.onBuscarFarmacia,
    required this.isLoadingBuscando,
    required this.tieneFarmaciaDestacada,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos IgnorePointer falso en toda la columna, los botones recibirán
    // los toques por defecto, y el espacio vacío dejará pasar los toques al mapa
    // gracias a la configuración del Stack en el Dashboard.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end, // FABs a la derecha
        children: [
          // 1. Botón FAB: Centrar en el Usuario
          FloatingActionButton(
            heroTag: 'btn_usuario',
            backgroundColor: Colors.white,
            foregroundColor: Colors.blueAccent,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onPressed: onCentrarUsuario,
            child: const Icon(Icons.my_location),
          ),
          
          const SizedBox(height: 16),
          
          // 2. Botón FAB: Centrar en Farmacia (Aparece solo si hay una buscada)
          if (tieneFarmaciaDestacada) ...[
            FloatingActionButton(
              heroTag: 'btn_farmacia',
              backgroundColor: Colors.white,
              foregroundColor: Colors.redAccent,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onPressed: onCentrarFarmacia,
              child: const Icon(Icons.local_pharmacy),
            ),
            const SizedBox(height: 16),
          ],

          // 3. Botón Principal Inferior: Buscar la más cercana
          SizedBox(
            width: double.infinity,
            height: 60, // Ligeramente más grande para que se sienta táctil y premium
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                elevation: 8,
                shadowColor: Colors.blueAccent.withValues(alpha: 0.5), // Brillo sutil
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: isLoadingBuscando ? null : onBuscarFarmacia,
              child: isLoadingBuscando
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      'Encontrar Farmacia Más Cercana',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
