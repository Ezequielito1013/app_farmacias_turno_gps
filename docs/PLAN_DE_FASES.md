# Plan de Desarrollo: App de Farmacias de Turno

> **Nota:** Aunque los diagramas y el diseño formal están en `documentacion.tex`, mantenemos aquí el registro rápido de nuestras decisiones de código (convenciones, tecnologías, etc.) para tenerlas siempre a mano durante el desarrollo sin tener que abrir el archivo de LaTeX.

## Acuerdos de Código y Estandarización (Aprobados)
1. **Idioma Global**: Todo el código fuente (nombres de variables, clases, archivos, funciones), la interfaz de usuario y los comentarios se escribirán en **Español** para facilitar tu comprensión y aprendizaje.
2. **Nombres de Archivos y Carpetas**: Siempre en minúsculas y separados por guiones bajos (`snake_case`). 
   * *Ejemplo*: `pantalla_inicio.dart`, `proveedor_autenticacion.dart`.
3. **Nombres de Clases y Nombres de Enums**: Siempre la primera letra de cada palabra en mayúscula (`PascalCase`). 
   * *Ejemplo*: `class PerfilUsuario`, `enum TipoDeClima`.
4. **Variables, Funciones y Valores de Enums**: Siempre en `camelCase` (estándar oficial de Dart para no levantar advertencias).
   * *Ejemplo Variables/Funciones*: `String nombreUsuario;`, `void obtenerFarmacias()`.
   * *Ejemplo Valores de Enum*: `soleado`, `nublado` (dentro del enum `TipoDeClima`).
5. **Widgets**: Por rendimiento, siempre extraeremos fragmentos de interfaz a clases `StatelessWidget` en archivos separados dentro de la carpeta `/widgets`, evitando usar métodos que devuelvan widgets.
6. **Principios SOLID**: Aplicación estricta de Responsabilidad Única (SRP). Evitaremos "God Functions" en favor de funciones y clases pequeñas y orquestadas.
7. **Restricción Cloud Free**: Prohibido usar APIs de pago. Usaremos mosaicos de CartoDB Positron (Light) de forma exclusiva para mantener estética minimalista.

## Decisiones Tecnológicas
* **Gestión de Estado**: Utilizaremos **Riverpod**.
* **Plataforma Objetivo**: Android.
* **SDK Android**: `minSdkVersion` 21 (Android 5.0) para compatibilidad con Firebase/Geolocator. Pruebas en emulador con API 33+.
* **Application ID**: `ezekim.farmaciasgps` (Identificador único de la aplicación).
* **Arquitectura**: **Feature-First**.

## Fases de Desarrollo

### Fase 0: Acuerdos y Diagramas
- [x] **0.1 Estilo de Código**: Confirmación de las reglas de estandarización y guardado de arquitectura.
- [x] **0.2 Arquitectura Visual**: Creación de diagramas C4 en LaTeX y configuración del flujo de datos.
- [x] **0.3 Configuración de Entorno**: Creación de `.gitignore` y limpieza de archivos auxiliares.

### Fase 1: Estructura Base y Configuración
- [x] Inicialización del proyecto Flutter.
- [x] Configuración del archivo `pubspec.yaml` con dependencias base (Riverpod, Dio, flutter_map, etc.).
- [x] Creación de la estructura de carpetas (Feature-First).

### Fase 2: Módulo de Autenticación (RU-01) - *Guiado paso a paso*
- [x] Creación y configuración guiada de Firebase para Android.
- [x] Implementación de la pantalla de Login y botón de Google.
- [x] Lógica de Riverpod para manejar y guardar la sesión iniciada.

### Fase 3: Módulo de Geolocalización y Mapas (RU-02) - *Guiado paso a paso*
- [x] Flujo de solicitud de permisos de ubicación en Android.
- [x] Servicio para obtener las coordenadas del dispositivo.
- [x] Configuración de la API de CartoDB Positron (`flutter_map`) e incrustación del mapa minimalista.

### Fase 4: Consumo de Datos (Farmacias y Clima) (RU-03)
- [x] Pruebas a la API del profesor y creación de modelos (Models).
- [x] Implementación de los servicios HTTP con `dio`.
- [x] Conectar la respuesta de la API con los marcadores del mapa libre y la UI del clima.

### Fase 5: Validaciones de Seguridad y Sesión (RU-01)
- [x] Bloqueo Total a No Autenticados: Impedir el acceso a las pantallas principales sin login.
- [x] Persistencia de Sesión: Redirección automática desde el splash/login hacia el mapa si ya hay una sesión activa.

### Fase 6: UI/UX y Refactorización
- [ ] Aplicar diseño moderno y estético a toda la aplicación.

### Fase 7: Entregables Finales y Cierre
- [ ] Elaboración del archivo `README.md` técnico (pasos de instalación, configuración de Firebase y breve explicación de la arquitectura).
- [ ] Agregar al docente (`sebasalazar`) como colaborador en el repositorio de GitHub.

## Plan de Verificación (QA)
- [x] **Fase 0**: Revisión y aprobación de los diagramas C4 y el compilado de LaTeX.
- [x] **Autenticación**: Probar en emulador Android que la sesión se guarde tras reiniciar la app.
- [x] **GPS (Fase 3)**: Validar que el emulador solicite permisos, lea ubicaciones simuladas y renderice el mapa con CartoDB.
- [ ] **API**: Validar que el panel muestre el clima correcto y las farmacias generen marcadores en el mapa interactivo.
