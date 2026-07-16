import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Anima el movimiento de la cámara del mapa hacia un destino con un efecto
/// de "Vuelo Parabólico". La cámara se aleja (zoom out) dinámicamente 
/// proporcional a la distancia a recorrer, y luego aterriza suavemente.
void animarMovimientoMapa({
  required MapController mapController,
  required LatLng destino,
  required double zoomDestino,
  required TickerProvider vsync,
}) {
  final latLngActual = mapController.camera.center;
  final zoomActual = mapController.camera.zoom;

  // Calculamos la distancia para determinar qué tanto debemos alejar la cámara
  final distanciaKm = const Distance().as(LengthUnit.Kilometer, latLngActual, destino);
  
  // Si está a más distancia, el zoom baja más. 
  // Limitamos el zoom mínimo a 11.0 (vista de región/ciudad)
  double zoomMinimo = zoomActual - (distanciaKm * 0.5);
  if (zoomMinimo < 11.0) zoomMinimo = 11.0;
  // Si están muy cerca, al menos hace un leve salto para el efecto visual
  if (zoomMinimo > zoomActual - 1.0) zoomMinimo = zoomActual - 1.0;

  // Ajustamos la duración de la animación basada en la distancia
  // Mínimo 1000ms (1 segundo) para viajes cortos, Máximo 2500ms (2.5 segundos)
  int duracionMs = 1000 + (distanciaKm * 150).toInt();
  if (duracionMs > 2500) duracionMs = 2500;

  final animationController = AnimationController(
    duration: Duration(milliseconds: duracionMs),
    vsync: vsync,
  );

  // Animación base para la traslación (Curva de aceleración y desaceleración)
  final animation = CurvedAnimation(
    parent: animationController,
    curve: Curves.easeInOutCubic,
  );

  // Tweens para interpolar la latitud y longitud directamente
  final latTween = Tween<double>(begin: latLngActual.latitude, end: destino.latitude);
  final lngTween = Tween<double>(begin: latLngActual.longitude, end: destino.longitude);
  
  // Secuencia de Zoom (Efecto Parabólico)
  final zoomSequence = TweenSequence<double>([
    // Mitad 1: Se aleja desde el zoom actual hasta el zoom mínimo
    TweenSequenceItem(
      tween: Tween<double>(begin: zoomActual, end: zoomMinimo)
          .chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 50,
    ),
    // Mitad 2: Se acerca desde el zoom mínimo hasta el zoom destino
    TweenSequenceItem(
      tween: Tween<double>(begin: zoomMinimo, end: zoomDestino)
          .chain(CurveTween(curve: Curves.easeInOutCubic)),
      weight: 50,
    ),
  ]);

  // En cada frame de la animación, movemos el mapa
  animationController.addListener(() {
    mapController.move(
      LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
      // Usamos el controlador lineal puro para la secuencia (las curvas ya están en los items)
      zoomSequence.evaluate(animationController),
    );
  });

  // Limpiamos memoria del controlador cuando termine
  animationController.addStatusListener((status) {
    if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
      animationController.dispose();
    }
  });

  // ¡Despegamos!
  animationController.forward();
}
