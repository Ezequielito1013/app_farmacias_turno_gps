/// Modelo que representa una observación meteorológica (MeteoObs)
/// obtenida desde la API de la UTEM.
class ModeloClima {
  final double temperatura;
  final double humedad;
  final double velocidadViento;
  final String fechaHora;

  ModeloClima({
    required this.temperatura,
    required this.humedad,
    required this.velocidadViento,
    required this.fechaHora,
  });

  /// Factory constructor para crear una instancia desde un JSON (Map).
  /// Esto reemplaza el uso de librerías como json_serializable.
  factory ModeloClima.fromJson(Map<String, dynamic> json) {
    return ModeloClima(
      // La API a veces puede enviar enteros en lugar de double (ej. 20 en vez de 20.0), 
      // usamos .toDouble() para evitar errores de casteo en tiempo de ejecución.
      temperatura: (json['temperatura'] ?? 0).toDouble(),
      humedad: (json['humedad'] ?? 0).toDouble(),
      velocidadViento: (json['velocidad_viento'] ?? 0).toDouble(),
      fechaHora: json['fecha_hora'] ?? '',
    );
  }
}
