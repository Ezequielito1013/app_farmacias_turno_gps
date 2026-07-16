import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../farmacias/proveedores/proveedor_farmacias.dart';

/// Tarjeta flotante (Glassmorphism) que se superpone en el Dashboard
/// para mostrar detalles y botones de enrutamiento al tocar un marcador.
class TarjetaDetallesFarmacia extends ConsumerWidget {
  const TarjetaDetallesFarmacia({super.key});

  Future<void> _abrirNavegador(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmacia = ref.watch(farmaciaSeleccionadaProvider);

    // Si el usuario no ha tocado ninguna farmacia, no renderiza nada
    if (farmacia == null) return const SizedBox.shrink();

    // Utilizamos Positioned para anclarnos directamente al Stack del Dashboard
    return Positioned(
      bottom: 100, // Flota por encima de la botonera inferior
      left: 24,
      right: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9), // Alta legibilidad
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera: Nombre y botón de cierre
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        farmacia.nombre,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () => ref.read(farmaciaSeleccionadaProvider.notifier).limpiar(),
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Dirección
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        farmacia.direccion,
                        style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                // Teléfono (Si existe y no es 0)
                if (farmacia.telefono.isNotEmpty && farmacia.telefono != '0') ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 18, color: Colors.green),
                      const SizedBox(width: 6),
                      Text(
                        farmacia.telefono,
                        style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Botones de Navegación
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4), // Azul Google
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => _abrirNavegador(
                            'https://www.google.com/maps/dir/?api=1&destination=${farmacia.latitud},${farmacia.longitud}'),
                        icon: const Icon(Icons.map, size: 18),
                        label: const Text('Maps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF33CCFF), // Celeste Waze
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => _abrirNavegador(
                            'https://waze.com/ul?ll=${farmacia.latitud},${farmacia.longitud}&navigate=yes'),
                        icon: const Icon(Icons.navigation, size: 18),
                        label: const Text('Waze', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
