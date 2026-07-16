# Plan de Implementación: Fase 2 - Autenticación

## Resumen
Este plan detalla los pasos técnicos para implementar la autenticación con Google en la aplicación, siguiendo la especificación aprobada (`docs/specs/auth_spec.md`).

## Componentes Principales
1. **Configuración de Firebase (Android)**: Integración del SDK nativo de Firebase mediante `google-services.json` y modificaciones a `build.gradle.kts`.
2. **Dependencias Flutter**: Instalación de `firebase_core`, `firebase_auth`, y `google_sign_in`.
3. **Capa de Servicios**: Interfaz con Firebase Authentication (`servicio_firebase.dart`).
4. **Capa de Estado (Riverpod)**: Proveedor global que escucha los cambios en la sesión del usuario (`proveedor_auth.dart`).
5. **Capa UI**: `PantallaLogin` y botón estándar de Google.

## Orden de Implementación (Dependencias)
1. Firebase no puede inicializarse sin el archivo `google-services.json`. **Bloqueante**.
2. Los servicios de Flutter no pueden crearse sin las librerías de Firebase instaladas.
3. La UI no puede interactuar sin el proveedor de estado (Riverpod).

## Riesgos y Mitigaciones
- **Riesgo**: El SHA-1 de Android no coincide con Firebase.
  **Mitigación**: Pediremos al usuario que extraiga el SHA-1 correcto desde su entorno local usando Gradle o Java keytool.
- **Riesgo**: Problemas de enlaces simbólicos o versiones en `build.gradle`.
  **Mitigación**: Seguir la documentación oficial más reciente para la integración del plugin `google-services` en `build.gradle.kts` (Kotlin DSL).

## Checkpoints de Verificación
- Checkpoint 1: La app compila después de inyectar `google-services.json`.
- Checkpoint 2: El botón de login abre el modal de cuentas de Google en el emulador.
- Checkpoint 3: Riverpod detecta el cambio y redirige (simulado o real).
