import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../proveedores/proveedor_gps.dart';
import '../../auth/proveedores/proveedor_auth.dart';
import '../../clima/widgets/widget_clima.dart';
import '../../farmacias/proveedores/proveedor_farmacias.dart';
import '../widgets/botones_mapa.dart';
import '../widgets/marcador_destacado.dart';
import '../widgets/marcador_usuario.dart';
import '../widgets/tarjeta_detalles_farmacia.dart';
import '../../../core/utils/animacion_mapa.dart';

/// Pantalla principal (Dashboard) rediseñada con Stack.
/// Superpone el clima, el mapa y los botones en una sola vista inmersiva.
class PantallaDashboard extends ConsumerStatefulWidget {
  const PantallaDashboard({super.key});

  @override
  ConsumerState<PantallaDashboard> createState() => _PantallaDashboardState();
}

class _PantallaDashboardState extends ConsumerState<PantallaDashboard> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  static const double _distanciaDeduplicacion = 20.0; // Distancia en metros para considerar duplicado
  bool _busquedaInicialRealizada = false;

  void _centrarUsuario() {
    final ubicacion = ref.read(ubicacionUsuarioProvider).value;
    if (ubicacion != null) {
      animarMovimientoMapa(
        mapController: _mapController,
        destino: LatLng(ubicacion.latitude, ubicacion.longitude),
        zoomDestino: 15.0,
        vsync: this,
      );
    }
  }

  void _centrarFarmaciaDestacada() {
    final farmacia = ref.read(farmaciaCercanaUtemProvider).value;
    if (farmacia != null) {
      animarMovimientoMapa(
        mapController: _mapController,
        destino: LatLng(farmacia.latitud, farmacia.longitud),
        zoomDestino: 16.0, // Más zoom para ver la farmacia de cerca
        vsync: this,
      );
    } else {
      _buscarFarmacia(); // Si el usuario toca el botón sin haber buscado, buscamos por él.
    }
  }

  void _buscarFarmacia() {
    final ubicacion = ref.read(ubicacionUsuarioProvider).value;
    if (ubicacion != null) {
      ref.read(ubicacionBusquedaFarmaciaProvider.notifier)
         .actualizar(LatLng(ubicacion.latitude, ubicacion.longitude));
      
      // La cámara se centrará automáticamente cuando el provider emita el nuevo estado
      // gracias a que reconstruirá el mapa con un initialCenter distinto, 
      // o bien el usuario apretará el FAB de centrar farmacia.
    }
  }

  @override
  Widget build(BuildContext context) {
    final ubicacionEstado = ref.watch(ubicacionUsuarioProvider);
    final minsalEstado = ref.watch(farmaciasMinsalProvider);
    final utemEstado = ref.watch(farmaciaCercanaUtemProvider);

    // Auto-centrado al encontrar la farmacia exitosamente
    ref.listen(farmaciaCercanaUtemProvider, (previous, next) {
      if (previous?.isLoading == true && next.hasValue && next.value != null) {
        // Esperamos un instante pequeño para que Flutter renderice el nuevo marcador primero
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _centrarFarmaciaDestacada();
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Farmacias de Turno', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => ref.read(servicioAuthProvider).cerrarSesion(),
          ),
        ],
      ),
      body: ubicacionEstado.when(
        loading: () => _buildLoadingState(),
        error: (err, stack) => _buildErrorState(err.toString()),
        data: (posicion) {
          if (posicion == null) return _buildErrorState('Ubicación desconocida.');
          
          final ubicacionUsuario = LatLng(posicion.latitude, posicion.longitude);
          
          // Disparamos la búsqueda automática la primera vez que tenemos GPS
          if (!_busquedaInicialRealizada) {
            _busquedaInicialRealizada = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _buscarFarmacia();
            });
          }

          final farmaciaUtem = utemEstado.value;
          final List<Marker> marcadores = [];
          const distanciaHelper = Distance();

          // A) Marcador del Usuario
          marcadores.add(
            Marker(
              point: ubicacionUsuario,
              width: 50,
              height: 50,
              rotate: true, // Sigue la rotación del usuario
              child: const MarcadorUsuario(),
            ),
          );

          // B) Marcadores de MINSAL (Con lógica de deduplicación)
          for (var farmaciaMinsal in minsalEstado) {
            final latLngMinsal = LatLng(farmaciaMinsal.latitud, farmaciaMinsal.longitud);
            bool esDuplicada = false;

            if (farmaciaUtem != null) {
              final latLngUtem = LatLng(farmaciaUtem.latitud, farmaciaUtem.longitud);
              final metros = distanciaHelper.as(LengthUnit.Meter, latLngMinsal, latLngUtem);
              if (metros < _distanciaDeduplicacion) {
                esDuplicada = true; // Omitir, es la misma que la del profesor
              }
            }

            if (!esDuplicada) {
              marcadores.add(
                Marker(
                  point: latLngMinsal,
                  width: 30,
                  height: 30,
                  rotate: true, // Sigue la rotación del usuario
                  child: GestureDetector(
                    onTap: () {
                      ref.read(farmaciaSeleccionadaProvider.notifier).seleccionar(farmaciaMinsal);
                    },
                    child: const Icon(Icons.local_pharmacy, color: Colors.green, size: 24),
                  ),
                ),
              );
            }
          }

          // C) Marcador Destacado de UTEM (Pieza conectada de la Task 2)
          if (farmaciaUtem != null) {
            marcadores.add(
              Marker(
                point: LatLng(farmaciaUtem.latitud, farmaciaUtem.longitud),
                width: 80, // Tamaño grande para dar espacio a la animación del radar
                height: 80,
                rotate: true, // Sigue la rotación del usuario
                child: GestureDetector(
                  onTap: () {
                    ref.read(farmaciaSeleccionadaProvider.notifier).seleccionar(farmaciaUtem);
                  },
                  child: const MarcadorDestacado(),
                ),
              ),
            );
          }

          return Stack(
            children: [
              // 1. Capa Base: Mapa a pantalla completa
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: ubicacionUsuario,
                  initialZoom: 14.0,
                  // Si el usuario toca el mapa vacío, cerramos la tarjeta
                  onTap: (_, _) {
                    ref.read(farmaciaSeleccionadaProvider.notifier).limpiar();
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                    userAgentPackageName: 'ezekim.farmaciasgps',
                    panBuffer: 2, // Precarga agresiva alrededor de la vista actual
                    keepBuffer: 3, // Mantiene en memoria las celdas recientes
                  ),
                  MarkerLayer(markers: marcadores),
                ],
              ),

              // 2. Capa Superior: Widget del Clima Flotante (Pieza de la Task 3)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: WidgetClima(ubicacion: ubicacionUsuario),
                ),
              ),

              // 3. Botonera Flotante (Abajo)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: BotonesMapa(
                  onCentrarUsuario: _centrarUsuario,
                  onCentrarFarmacia: _centrarFarmaciaDestacada,
                  onBuscarFarmacia: _buscarFarmacia,
                  isLoadingBuscando: utemEstado.isLoading,
                  tieneFarmaciaDestacada: farmaciaUtem != null,
                ),
              ),

              // 4. Tarjeta Flotante (Se dibuja al final para que sobreponga a los botones)
              const TarjetaDetallesFarmacia(),
            ],
          );
        },
      ),
    );
  }

  // Estado de carga elegante para no perder el aspecto de "tarjeta"
  Widget _buildLoadingState() {
    return Center(
      child: Container(
        height: 400,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8))
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.blueAccent),
              SizedBox(height: 16),
              Text('Obteniendo posición GPS...', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  // Estado de Error
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          'Error de Ubicación:\n$error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
