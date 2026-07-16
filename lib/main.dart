import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/pantallas/pantalla_login.dart';
import 'features/auth/proveedores/proveedor_auth.dart';
import 'features/mapa/pantallas/pantalla_dashboard.dart';

void main() async {
  // Asegura que los bindings de Flutter estén inicializados antes de interactuar con el código nativo (Firebase)
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa el motor de Firebase
  await Firebase.initializeApp();

  // ProviderScope inyecta el estado global de Riverpod a toda la aplicación
  runApp(
    const ProviderScope(
      child: AppFarmacias(),
    ),
  );
}

class AppFarmacias extends ConsumerWidget {
  const AppFarmacias({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Riverpod observa el flujo de autenticación (el Stream de Firebase)
    final estadoAuth = ref.watch(estadoAuthStateProvider);

    return MaterialApp(
      title: 'Farmacias de Turno',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      // Dependiendo del estado del usuario, Riverpod dibuja una pantalla u otra automáticamente
      home: estadoAuth.when(
        data: (usuario) {
          // Si el usuario existe (sesión activa), lo enviamos al mapa. Si no, al Login.
          if (usuario != null) {
            return const PantallaDashboard();
          }
          return const PantallaLogin();
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stackTrace) => Scaffold(
          body: Center(child: Text('Hubo un error cargando la sesión: $error')),
        ),
      ),
    );
  }
}
