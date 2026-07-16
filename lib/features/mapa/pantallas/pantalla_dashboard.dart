import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../proveedores/proveedor_gps.dart';
import '../../auth/proveedores/proveedor_auth.dart';

/// Pantalla principal que actúa como el Dashboard de la aplicación.
/// Muestra el clima (Fase 4), el mapa y el botón de búsqueda.
class PantallaDashboard extends ConsumerWidget {
  const PantallaDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado de la ubicación del usuario
    final ubicacionEstado = ref.watch(ubicacionUsuarioProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dashboard - Farmacias'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              ref.read(servicioAuthProvider).cerrarSesion();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Header: Widget del Clima (Mockup por ahora)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wb_sunny, color: Colors.orange, size: 30),
                SizedBox(width: 10),
                Text(
                  '22°C - Mayormente Soleado',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // 2. Cuerpo: Mapa Interactivo Minimalista
          Expanded(
            child: Center(
              child: Container(
                height: 350, // Altura fija para hacerlo más pequeño y minimalista
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: ubicacionEstado.when(
                    // Estado Cargando: Esperando al GPS y permisos
                    loading: () => const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Buscando señal GPS...'),
                        ],
                      ),
                    ),
                    // Estado Error: Permiso denegado o GPS apagado
                    error: (err, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error de Ubicación:\n$err',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    // Estado Éxito: Tenemos las coordenadas
                    data: (posicion) {
                      if (posicion == null) {
                        return const Center(child: Text('Ubicación desconocida.'));
                      }
                      final ubicacionUsuario = LatLng(
                        posicion.latitude,
                        posicion.longitude,
                      );

                      return FlutterMap(
                        options: MapOptions(
                          initialCenter: ubicacionUsuario,
                          initialZoom: 15.0,
                        ),
                        children: [
                          // Capa de los Mosaicos (CartoDB Positron - Minimalista y gratis)
                          TileLayer(
                            urlTemplate: 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.ezekim.farmaciasgps',
                          ),
                          // Capa de Marcadores
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: ubicacionUsuario,
                                width: 50,
                                height: 50,
                                child: const Icon(
                                  Icons.person_pin_circle,
                                  color: Colors.blueAccent,
                                  size: 50,
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
            ),
          ),

          // 3. Footer: Botón de Acción Principal
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  // Lógica de Fase 4: Calcular distancia a las farmacias
                  debugPrint('Buscar farmacias más cercanas presionado');
                },
                child: const Text(
                  'Encontrar Farmacia Más Cercana',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
