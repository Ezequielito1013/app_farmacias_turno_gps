import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../proveedores/proveedor_gps.dart';
import '../../auth/proveedores/proveedor_auth.dart';
import '../../clima/widgets/widget_clima.dart';
import '../../farmacias/proveedores/proveedor_farmacias.dart';

/// Pantalla principal que actúa como el Dashboard de la aplicación.
/// Muestra el clima (Fase 4), el mapa y el botón de búsqueda.
class PantallaDashboard extends ConsumerWidget {
  const PantallaDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado de la ubicación del usuario
    final ubicacionEstado = ref.watch(ubicacionUsuarioProvider);

    // Escuchamos las farmacias globales del MINSAL
    final minsalEstado = ref.watch(farmaciasMinsalProvider);

    // Escuchamos la farmacia destacada de la UTEM
    final utemEstado = ref.watch(farmaciaCercanaUtemProvider);

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
          // 1. Header: Widget del Clima Dinámico
          ubicacionEstado.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Esperando GPS para obtener el clima...'),
            ),
            error: (err, stack) => const SizedBox.shrink(),
            data: (posicion) {
              if (posicion == null) return const SizedBox.shrink();
              return WidgetClima(
                ubicacion: LatLng(posicion.latitude, posicion.longitude),
              );
            },
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

                      // Construimos la lista de marcadores dinámicamente
                      final List<Marker> marcadores = [];

                      // A) Marcador del Usuario (Azul)
                      marcadores.add(
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
                      );

                      // B) Marcadores de MINSAL (Reactivados)
                      for (var farmacia in minsalEstado) {
                        marcadores.add(
                          Marker(
                            point: LatLng(farmacia.latitud, farmacia.longitud),
                            width: 30,
                            height: 30,
                            child: const Icon(
                              Icons.local_pharmacy,
                              color: Colors.green,
                              size: 20,
                            ),
                          ),
                        );
                      }

                      // C) Marcador Destacado de UTEM (Rojo gigante)
                      utemEstado.whenData((farmaciaUtem) {
                        if (farmaciaUtem != null) {
                          marcadores.add(
                            Marker(
                              point: LatLng(farmaciaUtem.latitud, farmaciaUtem.longitud),
                              width: 60,
                              height: 60,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.redAccent,
                                size: 60,
                              ),
                            ),
                          );
                        }
                      });

                      return FlutterMap(
                        options: MapOptions(
                          initialCenter: ubicacionUsuario,
                          initialZoom: 14.0,
                        ),
                        children: [
                          // Capa de los Mosaicos (CartoDB Positron - Minimalista y gratis)
                          TileLayer(
                            urlTemplate: 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.ezekim.farmaciasgps',
                          ),
                          // Capa de Marcadores (Usuario + MINSAL + UTEM)
                          MarkerLayer(
                            markers: marcadores,
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
                  // Le decimos a Riverpod que el usuario apretó buscar,
                  // actualizando el estado de la ubicación a buscar.
                  final pos = ref.read(ubicacionUsuarioProvider).value;
                  if (pos != null) {
                    ref.read(ubicacionBusquedaFarmaciaProvider.notifier).actualizar(
                        LatLng(pos.latitude, pos.longitude));
                  }
                },
                child: utemEstado.isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
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
