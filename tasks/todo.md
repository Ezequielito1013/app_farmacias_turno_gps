# Tareas: Fase 2 - Autenticación

- [x] Tarea 1: Configurar Proyecto en Consola de Firebase
  - Aceptación: Proyecto creado con app Android (`ezekim.farmaciasgps`) y SHA-1 local registrado.
  - Verificar: Archivo `google-services.json` entregado por el usuario y guardado en `android/app/`.
  - Archivos: Ninguno por parte del agente (acción humana).

- [x] Tarea 2: Integrar Firebase Nativo y Dependencias Flutter
  - Aceptación: Plugins agregados al Gradle y paquetes instalados en pubspec.
  - Verificar: Ejecución exitosa de `flutter pub get` y compilación en Android.
  - Archivos: `android/build.gradle.kts`, `android/app/build.gradle.kts`, `pubspec.yaml`.

- [x] Tarea 3: Capa de Servicios y Modelos
  - Aceptación: Funciones abstractas para login/logout conectadas a Firebase.
  - Verificar: Análisis de sintaxis (`flutter analyze`).
  - Archivos: `lib/features/auth/modelos/usuario_modelo.dart`, `lib/features/auth/servicios/servicio_auth.dart`.

- [x] Tarea 4: Capa de Estado (Riverpod)
  - Aceptación: Proveedor que escucha `authStateChanges` de Firebase.
  - Verificar: Análisis estático.
  - Archivos: `lib/features/auth/proveedores/proveedor_auth.dart`.

- [x] Tarea 5: Capa Visual y Redirección (UI)
  - Aceptación: Pantalla de Login estándar creada, y `main.dart` configurado para mostrar login o Home dependiendo del estado.
  - Verificar: Ejecución exitosa de `flutter run` en emulador y prueba de login manual.
  - Archivos: `lib/features/auth/pantallas/pantalla_login.dart`, `lib/features/auth/widgets/boton_google.dart`, `lib/main.dart`.
