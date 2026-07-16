import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';
import '../../features/auth/proveedores/proveedor_auth.dart';

/// Proveedor global del cliente HTTP Dio.
/// Está configurado con la URL base de la UTEM y un interceptor que
/// inyecta automáticamente el Token de Google en cada petición.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  // Configuración base de la API de la UTEM
  dio.options.baseUrl = 'https://api.sebastian.cl/cmutem/v1/';
  dio.options.connectTimeout = const Duration(seconds: 15);
  dio.options.receiveTimeout = const Duration(seconds: 15);

  // Bypass SSL para dispositivos físicos en Release (igual que MINSAL)
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    },
  );

  // Interceptor de seguridad
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // 1. Obtenemos la instancia global de GoogleSignIn
      final servicioAuth = ref.read(servicioAuthProvider);
      final googleSignIn = servicioAuth.googleSignIn;
      
      // 2. Intentamos recuperar el usuario logueado
      var cuentaGoogle = googleSignIn.currentUser;
      
      // En Android Release, a veces currentUser es nulo si se cerró la app. 
      // Si es así, intentamos restaurar la sesión silenciosamente.
      if (cuentaGoogle == null) {
        try {
          cuentaGoogle = await googleSignIn.signInSilently();
        } catch (e) {
          logger.e('Error en signInSilently: $e');
        }
      }
      
      if (cuentaGoogle != null) {
        try {
          final auth = await cuentaGoogle.authentication;
          if (auth.idToken != null) {
            // Lo inyectamos en la cabecera "Authorization" tal como funcionó en USB
            options.headers['Authorization'] = 'Bearer ${auth.idToken}';
          } else {
            logger.w('Dio Interceptor: ¡Token JWT de Google es nulo!');
            ref.read(servicioAuthProvider).cerrarSesion();
            throw DioException(
              requestOptions: options,
              error: 'Sesión inválida: idToken nulo. Inicia sesión nuevamente.',
            );
          }
        } catch (e) {
          logger.e('Error obteniendo auth de Google: $e');
          ref.read(servicioAuthProvider).cerrarSesion();
          throw DioException(
            requestOptions: options,
            error: 'Error de Google al obtener token. Inicia sesión nuevamente.',
          );
        }
      } else {
        logger.w('Dio Interceptor: ¡No hay usuario autenticado en Google!');
        ref.read(servicioAuthProvider).cerrarSesion();
        throw DioException(
          requestOptions: options,
          error: 'Sesión caducada. Inicia sesión nuevamente.',
        );
      }
      
      // Continuamos el viaje de la petición HTTP hacia el servidor
      return handler.next(options);
    },
    onError: (DioException e, handler) {
      // Manejo profesional de expiración de token
      if (e.response?.statusCode == 401) {
        logger.w('Token expirado o inválido (401). Cerrando sesión automáticamente...');
        ref.read(servicioAuthProvider).cerrarSesion();
      } else {
        logger.e('DioError en [${e.requestOptions.method}] ${e.requestOptions.uri}: ${e.message}');
        if (e.response != null) {
          logger.e('Respuesta del Servidor: ${e.response?.data}');
        }
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
