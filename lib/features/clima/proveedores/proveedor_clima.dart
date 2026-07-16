import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/api/proveedor_dio.dart';
import '../../../core/utils/logger.dart';
import '../modelos/modelo_clima.dart';

/// Un FutureProvider.family nos permite pasarle un parámetro (LatLng)
/// a la petición asíncrona.
final climaProvider = FutureProvider.family<ModeloClima, LatLng>((ref, ubicacion) async {
  // Obtenemos la instancia de Dio ya configurada con la URL y el Token
  final dio = ref.watch(dioProvider);

  try {
    // Extraemos y redondeamos a 5 decimales para evitar problemas con la API
    final lat = ubicacion.latitude.toString();
    final lng = ubicacion.longitude.toString();

    logger.i('Consultando clima en ($lat, $lng)...');
    // Hacemos la petición GET al endpoint sin slash inicial (evita doble slash)
    final response = await dio.get('clima/$lat/$lng');

    logger.i('Clima obtenido exitosamente: ${response.data['temperatura']}°C');
    // Convertimos el JSON de respuesta a nuestro modelo Dart fuertemente tipado
    return ModeloClima.fromJson(response.data);
  } catch (e) {
    // Si la API falla (ej. 404 No hay observaciones cerca, o 500), lanzamos el error
    // para que Riverpod lo atrape y muestre un estado de error en la UI.
    logger.e('Error obteniendo el clima', error: e);
    throw Exception('Error al obtener el clima: $e');
  }
});
