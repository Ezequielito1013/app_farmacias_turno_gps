# Enunciado Original del Proyecto

A continuación se incluye la transcripción original del documento `Proyecto Flutter.docx` entregado por el profesor:

**Universidad Tecnológica Metropolitana**  
**Departamento de Computación e Informática**  
**Computación Móvil**  
**Profesor:** Sebastián Salazar Molina  

**Enunciado: Trabajo Práctico – Desarrollo de Aplicación Móvil con Flutter**  
**Fecha:** 17 de julio del 2026

### Contexto y Problemática
Se solicita diseñar y desarrollar una aplicación móvil multiplataforma utilizando el framework Flutter, que integre servicios de autenticación de terceros (Google Sign-In), sensores del dispositivo (GPS) y consumo de servicios web RESTful. El objetivo es implementar una aplicación que para un usuario autenticado, le muestre las farmacias que están de turno más cerca de su ubicación, la cual debe ser obtenida desde el GPS del celular y las condiciones climáticas cercanas a la ubicación para evaluar si vale la pena o no hacer el desplazamiento.

### Requisitos Técnicos Obligatorios
El desarrollo de la aplicación debe cumplir estrictamente con las siguientes tecnologías:
* **Framework**: Flutter (lenguaje Dart).
* **Arquitectura**: Se debe aplicar un patrón de arquitectura limpia (Clean Architecture) o estado reactivo (BLoC, Provider o Riverpod).
* **Autenticación**: Implementación de Google Sign-In para el inicio de sesión. La aplicación no debe permitir el acceso a las funcionalidades principales sin estar autenticado.
* **Geolocalización**: Uso del sensor GPS del dispositivo para obtener la posición actual del usuario y mostrarla en un mapa interactivo.
* **Consumo de API**: Conexión al servicio REST proporcionado en la siguiente documentación OpenAPI (Swagger): `https://api.sebastian.cl/cmutem/swagger-ui/index.html`. Se debe usar el paquete `http` o `dio` para las peticiones y generar los modelos de datos a partir del JSON.

### Requisitos Funcionales (Historias de Usuario)
* **Módulo de Autenticación (RU-01)**: Como usuario, quiero poder iniciar sesión con mi cuenta de Google para acceder a la aplicación. El sistema debe guardar el estado de la sesión (persistencia) para no tener que loguearse cada vez que abra la app.
* **Módulo de Geolocalización (RU-02)**: Como usuario autenticado, quiero ver un mapa que muestre mi ubicación actual en tiempo real usando el GPS del teléfono. La aplicación debe solicitar los permisos de ubicación correspondientes de manera amigable.
* **Módulo de Consumo de Datos (RU-03)**: Como usuario, quiero poder consultar la información de las farmacias que están más cerca de mi posición y las condiciones climáticas, para considerar si vale la pena el desplazamiento.

*Nota: Se espera que los estudiantes apliquen su creatividad en el diseño de la aplicación, parte de la evaluación es la investigación de técnicas novedosas y un diseño que sea a la vez atractivo y amigable.*

### Entregables
El trabajo debe ser entregado en un repositorio público de GitHub o GitLab, el cual debe contener:
* **Código Fuente**: Organizado en una estructura de carpetas clara (separación de pantallas, widgets, modelos, proveedores/blocs y servicios). Deben agregar al docente (`sebasalazar`) como colaborador de su repositorio GitHub.
* **Archivo README.md**: Que incluya:
  * Título y descripción del proyecto.
  * Instrucciones detalladas de cómo instalar y ejecutar el proyecto (configuración de Firebase, Mapas, etc.).
  * Explicación breve de la arquitectura utilizada.

La fecha máxima de entrega del proyecto es el 17 de julio de 2026 a las 23:59:59.999999 hora continental de Chile. La similitud entre códigos se asumirá como “copia” y se evaluará con la nota mínima.

### Criterios de Evaluación
| Criterio | Peso | Descripción |
| :--- | :--- | :--- |
| **Google Sign-In** | 20% | Login fluido, manejo de errores, persistencia de sesión y cierre de sesión (logout). |
| **Uso de GPS y Mapas** | 25% | Correcta solicitud de permisos, obtención precisa de coordenadas, renderizado del mapa y marcador del usuario. |
| **Consumo del API** | 30% | Correcta lectura de la documentación Swagger, parseo de JSON a modelos Dart (Serialization), manejo de estados de carga (Loading) y errores (Error handling). |
| **Calidad de Código y UI** | 15% | Uso de widgets Stateless/Stateful adecuados, diseño responsivo, jerarquía visual, uso de Constantes y buena nomenclatura. |
| **Documentación en código** | 10% | README completo, repositorio ordenado con commits claros, y código documentado. |
