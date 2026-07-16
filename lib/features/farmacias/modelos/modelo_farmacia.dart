/// Modelo que representa una Farmacia (tanto de UTEM como de MINSAL).
class ModeloFarmacia {
  final String nombre;
  final String direccion;
  final double latitud;
  final double longitud;
  final String telefono;
  final String? apertura;
  final String? cierre;
  final String? dia;

  ModeloFarmacia({
    required this.nombre,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    this.telefono = '',
    this.apertura,
    this.cierre,
    this.dia,
  });

  /// Factory para parsear el JSON que devuelve la API de la UTEM (Swagger)
  factory ModeloFarmacia.fromJsonUtem(Map<String, dynamic> json) {
    final cadena = json['cadena']?.toString().trim() ?? '';
    final nombreBase = json['nombre']?.toString().trim() ?? 'Farmacia Desconocida';
    final nombreCombinado = cadena.isNotEmpty ? '$cadena - $nombreBase' : nombreBase;

    return ModeloFarmacia(
      nombre: nombreCombinado,
      direccion: json['direccion'] ?? 'Sin dirección',
      latitud: (json['latitude'] ?? 0).toDouble(),
      longitud: (json['longitude'] ?? 0).toDouble(),
      telefono: json['telefono']?.toString() ?? '',
      apertura: json['apertura_normal']?.toString(),
      cierre: json['cierre_normal']?.toString(),
    );
  }

  /// Factory para parsear el JSON que devuelve la API pública del MINSAL
  factory ModeloFarmacia.fromJsonMinsal(Map<String, dynamic> json) {
    // MINSAL a veces devuelve lat/lng como Strings, así que los parseamos de forma segura
    return ModeloFarmacia(
      nombre: json['local_nombre'] ?? 'Farmacia MINSAL',
      direccion: json['local_direccion'] ?? 'Sin dirección',
      latitud: double.tryParse(json['local_lat']?.toString() ?? '0') ?? 0.0,
      longitud: double.tryParse(json['local_lng']?.toString() ?? '0') ?? 0.0,
      telefono: json['local_telefono']?.toString() ?? '',
      apertura: json['funcionamiento_hora_apertura']?.toString(),
      cierre: json['funcionamiento_hora_cierre']?.toString(),
      dia: json['funcionamiento_dia']?.toString(),
    );
  }
}
