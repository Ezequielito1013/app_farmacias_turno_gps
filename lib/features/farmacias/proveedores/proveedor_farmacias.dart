import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/api/proveedor_dio.dart';
import '../../../core/utils/logger.dart';
import '../modelos/modelo_farmacia.dart';
import '../utils/filtro_horario.dart';
import '../../mapa/proveedores/proveedor_gps.dart';

/// 1. PROVEEDOR MINSAL RAW (Interno)
/// Descarga TODAS las farmacias de turno del país una sola vez.
final farmaciasMinsalRawProvider = FutureProvider<List<ModeloFarmacia>>((ref) async {
  // BYPASS SSL y uso directo de HttpClient (dart:io) porque el servidor del MINSAL 
  // lanza errores de conexión ("Connection closed before full header") si usamos Dio.
  final client = HttpClient();
  client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

  try {
    logger.i('Consultando API del MINSAL (getLocalesTurnos.php)...');
    final request = await client.getUrl(Uri.parse('https://midas.minsal.cl/farmacia_v2/WS/getLocalesTurnos.php'));
    final response = await request.close();
    final bodyString = await response.transform(utf8.decoder).join();
    
    final List<dynamic> data = jsonDecode(bodyString);
    logger.i('MINSAL respondió con ${data.length} farmacias de turno.');

    return data.map((json) => ModeloFarmacia.fromJsonMinsal(json)).toList();
  } catch (e) {
    logger.e('Error crítico cargando MINSAL', error: e);
    return [];
  } finally {
    client.close();
  }
});

/// 1.1 PROVEEDOR MINSAL (Filtrado)
/// Escucha la lista completa de farmacias y la ubicación del usuario.
/// Filtra las farmacias de forma síncrona a un radio de 5km para no colapsar el mapa.
final farmaciasMinsalProvider = Provider<List<ModeloFarmacia>>((ref) {
  // Observamos la data cruda (2047 farmacias)
  final rawData = ref.watch(farmaciasMinsalRawProvider).value ?? [];
  
  // Observamos el último evento emitido por el GPS de forma reactiva (sin .future para evitar cuelgues)
  final ubicacionActual = ref.watch(ubicacionUsuarioProvider).value;

  if (ubicacionActual == null || rawData.isEmpty) {
    return []; // Aún no hay GPS o aún no cargan las farmacias
  }

  const double radioMaximoMetros = 50000.0; // 50 km (aumentado para encontrar farmacias en madrugada)
  final distancia = const Distance();
  final ahora = DateTime.now();

  // Filtramos la lista síncronamente
  final filtradas = rawData.where((farmacia) {
    // 1. Filtro Espacial (Cálculo Haversine)
    final d = distancia.as(
      LengthUnit.Meter,
      LatLng(ubicacionActual.latitude, ubicacionActual.longitude),
      LatLng(farmacia.latitud, farmacia.longitud),
    );

    if (d > radioMaximoMetros) return false;

    // 2. Filtro Temporal y de Día
    return FiltroHorario.estaAbiertaYEnDia(farmacia.apertura, farmacia.cierre, farmacia.dia, ahora);
  }).toList();
  return filtradas;
});

/// 2. ESTADO DE BÚSQUEDA
/// Almacena la coordenada exacta en el momento que el usuario aprieta el botón "Buscar".
/// Inicia nulo porque aún no ha apretado el botón.
class UbicacionBusquedaNotifier extends Notifier<LatLng?> {
  @override
  LatLng? build() => null;

  void actualizar(LatLng nueva) {
    state = nueva;
  }
}

final ubicacionBusquedaFarmaciaProvider = NotifierProvider<UbicacionBusquedaNotifier, LatLng?>(
  () => UbicacionBusquedaNotifier(),
);

/// 3. PROVEEDOR UTEM (Específico)
/// Reacciona cuando el usuario aprieta el botón, y descubre la farmacia más cercana a destacar.
final farmaciaCercanaUtemProvider = FutureProvider<ModeloFarmacia?>((ref) async {
  // Observamos si el usuario apretó el botón (si hay coordenadas guardadas)
  final ubicacion = ref.watch(ubicacionBusquedaFarmaciaProvider);
  
  if (ubicacion == null) return null; // No buscar si no han apretado el botón

  final dio = ref.watch(dioProvider); // Este Dio SI tiene el token inyectado

  try {
    final lat = ubicacion.latitude.toString();
    final lng = ubicacion.longitude.toString();
    
    // Sin slash inicial para evitar https://api.../v1//farmacias
    logger.i('Consultando farmacia más cercana a la UTEM para ($lat, $lng)...');
    final response = await dio.get('farmacias/$lat/$lng');
    final farmaciaMapeada = ModeloFarmacia.fromJsonUtem(response.data);
    logger.i('UTEM respondió con farmacia: ${farmaciaMapeada.nombre}');
    return farmaciaMapeada;
  } catch (e) {
    logger.e('Error crítico consultando UTEM', error: e);
    throw Exception('Error al contactar con la API de UTEM: $e');
  }
});

/// 4. ESTADO DE FARMACIA SELECCIONADA
/// Almacena la farmacia que el usuario ha tocado en el mapa para mostrar sus detalles.
class FarmaciaSeleccionadaNotifier extends Notifier<ModeloFarmacia?> {
  @override
  ModeloFarmacia? build() => null;

  void seleccionar(ModeloFarmacia farmacia) {
    state = farmacia;
  }

  void limpiar() {
    state = null;
  }
}

final farmaciaSeleccionadaProvider = NotifierProvider<FarmaciaSeleccionadaNotifier, ModeloFarmacia?>(
  () => FarmaciaSeleccionadaNotifier(),
);
