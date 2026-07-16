import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Anima el movimiento de la cámara del mapa hacia un destino de forma suave.
/// Debido a que `flutter_map` no tiene animaciones nativas integradas,
/// utilizamos el `AnimationController` estándar de Flutter iterando sobre `mapController.move`.
void animarMovimientoMapa({
  required MapController mapController,
  required LatLng destino,
  required double zoomDestino,
  required TickerProvider vsync,
}) {
  // Obtenemos la posición actual de la cámara
  final latLngActual = mapController.camera.center;
  final zoomActual = mapController.camera.zoom;

  // Creamos el AnimationController para durar medio segundo
  final animationController = AnimationController(
    duration: const Duration(milliseconds: 600),
    vsync: vsync,
  );

  // Animación con una curva suave de aceleración y frenado
  final animation = CurvedAnimation(
    parent: animationController,
    curve: Curves.fastOutSlowIn,
  );

  // Tweens para interpolar la latitud, longitud y zoom
  final latTween = Tween<double>(
    begin: latLngActual.latitude,
    end: destino.latitude,
  );
  
  final lngTween = Tween<double>(
    begin: latLngActual.longitude,
    end: destino.longitude,
  );
  
  final zoomTween = Tween<double>(
    begin: zoomActual,
    end: zoomDestino,
  );

  // En cada frame de la animación, movemos el mapa
  animationController.addListener(() {
    mapController.move(
      LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
      zoomTween.evaluate(animation),
    );
  });

  // Limpiamos el controlador de memoria cuando termine o se interrumpa
  animationController.addStatusListener((status) {
    if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
      animationController.dispose();
    }
  });

  // Iniciamos la animación
  animationController.forward();
}
