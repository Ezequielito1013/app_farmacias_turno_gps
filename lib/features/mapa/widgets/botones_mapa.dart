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
          
          // 2. Botón FAB: Buscar o Centrar en Farmacia de Turno
          FloatingActionButton(
            heroTag: 'btn_farmacia',
            backgroundColor: Colors.white,
            foregroundColor: Colors.redAccent,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onPressed: isLoadingBuscando ? null : onCentrarFarmacia,
            child: isLoadingBuscando 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.redAccent, strokeWidth: 2))
              : const Icon(Icons.local_pharmacy),
          ),
        ],
      ),
    );
  }
}
