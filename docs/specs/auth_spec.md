# Spec: Fase 2 - Módulo de Autenticación

## Objetivo
Implementar un sistema de inicio de sesión utilizando Firebase Google Sign-In. El usuario debe poder iniciar sesión con su cuenta de Google y mantener la sesión activa. Si la sesión existe, debe entrar directo al mapa. Si no, debe ver una pantalla de Login.

## Tech Stack
- Framework: Flutter (Android)
- Gestión de Estado: Riverpod (`flutter_riverpod: ^2.4.9`)
- Autenticación: Firebase Core + Google Sign-In (`firebase_core`, `google_sign_in`, `firebase_auth`)

## Comandos
- Build/Run: `flutter run`
- Clean: `flutter clean && flutter pub get`

## Estructura del Proyecto
```text
lib/features/auth/
  ├── modelos/
  ├── pantallas/
  ├── proveedores/
  ├── servicios/
  └── widgets/
```

## Estilo de Código
Todo el código en **Español** (Clases, variables, comentarios).
Uso estricto de `StatelessWidget` y extracción de componentes. Reglas SOLID (Responsabilidad Única).

## Estrategia de Pruebas
- Verificación manual en Emulador de Android.
- Comprobación visual en la consola de Firebase Authentication.
- Prueba de persistencia (Cerrar la app y volver a abrirla).

## Límites (Boundaries)
- Siempre hacer: Separar la lógica visual (`pantallas`) de la lógica de conexión (`servicios`).
- Preguntar antes de: Añadir dependencias que requieran cambiar archivos nativos de Android.
- Nunca hacer: Usar servicios de pago. Todo debe correr local y gratis (Cloud Free).

## Criterios de Éxito
1. La aplicación compila en Android con Firebase configurado.
2. Existe un botón "Iniciar sesión con Google" que levanta el modal nativo.
3. El estado global (Riverpod) reconoce si el usuario está logueado o no.

## Preguntas Abiertas
1. ¿Configuramos el proyecto de Firebase juntos paso a paso?
2. ¿El diseño del botón será estándar o llevará algún logo de la UTEM?
