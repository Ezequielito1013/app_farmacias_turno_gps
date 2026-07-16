import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../proveedores/proveedor_clima.dart';

/// Widget premium del clima con estilo Glassmorphism.
/// Se conecta a Riverpod para mostrar el clima actual sobre el mapa de forma flotante.
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: climaEstado.when(
            // Estado Cargando
            loading: () => const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent),
                ),
                SizedBox(width: 12),
                Text(
                  'Consultando clima...',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
                ),
              ],
            ),
            // Estado Error
            error: (err, stack) {
              final String mensaje = err.toString().contains('404')
                  ? 'Fuera de cobertura UTEM'
                  : 'Clima no disponible';
              
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    mensaje,
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                ],
              );
            },
            // Estado Éxito
            data: (clima) {
              final esLluvia = clima.humedad > 80;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: esLluvia ? Colors.blue.shade50 : Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      esLluvia ? Icons.water_drop : Icons.wb_sunny,
                      color: esLluvia ? Colors.blue : Colors.orange,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${clima.temperatura.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Humedad: ${clima.humedad.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
