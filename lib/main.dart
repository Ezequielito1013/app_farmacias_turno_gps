import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/pantallas/pantalla_login.dart';
import 'features/auth/proveedores/proveedor_auth.dart';

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
            return const PantallaMapaTemporal();
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

/// Placeholder temporal (Fase 2) que será reemplazado en la Fase 3 por el mapa real.
class PantallaMapaTemporal extends ConsumerWidget {
  const PantallaMapaTemporal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmacias Cercanas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              // El cierre de sesión actualiza el Stream y nos expulsa al Login al instante
              ref.read(servicioAuthProvider).cerrarSesion();
            },
          )
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            '¡Login Exitoso!\n\nEstás autenticado con Google de forma segura.\nAquí construiremos el Mapa y GPS en la próxima fase.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.green),
          ),
        ),
      ),
    );
  }
}
