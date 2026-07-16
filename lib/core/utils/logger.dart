import 'package:logger/logger.dart';

/// Instancia global del Logger para toda la aplicación.
/// Muestra logs con colores bonitos y formato legible en la consola de Flutter.
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // No imprimir llamadas de métodos por defecto para no ensuciar
    errorMethodCount: 5, // Si es un error, imprime hasta 5 niveles del stack trace
    lineLength: 80, // Ancho de línea
    colors: true, // Colores en la consola
    printEmojis: true, // Emojis para identificar rápido (💡, 🐛, ❌, etc.)
    dateTimeFormat: DateTimeFormat.none, // No imprimir hora para que sea más limpio (el IDE ya lo hace)
  ),
);
