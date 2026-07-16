import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Proveedor global del cliente HTTP Dio.
/// Está configurado con la URL base de la UTEM y un interceptor que
/// inyecta automáticamente el Token de Google en cada petición.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  // Configuración base de la API de la UTEM
  dio.options.baseUrl = 'https://api.sebastian.cl/cmutem/v1/';
  dio.options.connectTimeout = const Duration(seconds: 15);
  dio.options.receiveTimeout = const Duration(seconds: 15);

  // Interceptor de seguridad
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // 1. Instanciamos Google SignIn
      final googleSignIn = GoogleSignIn();
      
      // 2. Intentamos recuperar el usuario logueado
      var cuentaGoogle = googleSignIn.currentUser;
      cuentaGoogle ??= await googleSignIn.signInSilently();
      
      if (cuentaGoogle != null) {
        final auth = await cuentaGoogle.authentication;
        if (auth.idToken != null) {
          // Lo inyectamos en la cabecera "Authorization"
          options.headers['Authorization'] = 'Bearer ${auth.idToken}';
        } else {
          print('Dio Interceptor: ¡Token JWT de Google es nulo!');
        }
      } else {
        print('Dio Interceptor: ¡No hay usuario autenticado en Google!');
      }
      
      // Continuamos el viaje de la petición HTTP hacia el servidor
      return handler.next(options);
    },
    onError: (DioException e, handler) {
      // Si la API falla, pasamos el error para manejarlo en los proveedores específicos
      print('DioError en [${e.requestOptions.method}] ${e.requestOptions.uri}: ${e.message}');
      if (e.response != null) {
        print('Respuesta del Servidor: ${e.response?.data}');
      }
      return handler.next(e);
    },
  ));

  // Agregamos un LogInterceptor para ver TODA la traza de la petición en la consola (Fase 4.1)
  dio.interceptors.add(LogInterceptor(
    requestHeader: true,
    responseBody: true,
    error: true,
  ));

  return dio;
});
