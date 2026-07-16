import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../proveedores/proveedor_clima.dart';

/// Widget minimalista que muestra la tarjeta de clima.
/// Se conecta a Riverpod para escuchar el estado de la petición a la API.
class WidgetClima extends ConsumerWidget {
  final LatLng ubicacion;

  const WidgetClima({
    super.key,
    required this.ubicacion,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Al pasarle la ubicación al family provider, Riverpod automáticamente
    // hace la petición GET a la API en segundo plano.
    final climaEstado = ref.watch(climaProvider(ubicacion));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: climaEstado.when(
        // Estado: Cargando
        loading: () => const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('Consultando clima...'),
          ],
        ),
        // Estado: Error (Ej: La API se cayó o falló el token)
        error: (err, stack) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: Colors.grey),
            const SizedBox(width: 10),
            Text(
              'Clima no disponible',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
        // Estado: Éxito (Recibimos el ModeloClima)
        data: (clima) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lógica simple: Si hay lluvia o mucha humedad, cambiamos el ícono
              Icon(
                clima.humedad > 80 ? Icons.water_drop : Icons.wb_sunny,
                color: clima.humedad > 80 ? Colors.blue : Colors.orange,
                size: 30,
              ),
              const SizedBox(width: 10),
              Text(
                '${clima.temperatura.toStringAsFixed(1)}°C - Humedad: ${clima.humedad.toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );
  }
}
