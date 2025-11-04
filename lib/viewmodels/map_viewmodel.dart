import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
/// ===================
class MapViewModel extends ChangeNotifier {
  LatLng? fromLocation;
  LatLng? toLocation;

  Marker? fromMarker;
  Marker? toMarker;
  Marker? bikeMarker;

  List<LatLng> polylineCoordinates = [];
  GoogleMapController? mapController;
  Timer? animationTimer;

  void setFromLocation(LatLng from) {
    fromLocation = from;

    fromMarker = Marker(
      markerId: const MarkerId('from'),
      position: from,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    bikeMarker = Marker(
      markerId: const MarkerId('bike'),
      position: from,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    _updatePolyline();
    notifyListeners();
  }

  void setToLocation(LatLng to) {
    toLocation = to;

    toMarker = Marker(
      markerId: const MarkerId('to'),
      position: to,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    _updatePolyline();
    notifyListeners();

    // Start bike animation only if both From & To are set
    if (fromLocation != null && toLocation != null) {
      startBikeAnimation();
    }
  }

  void _updatePolyline() {
    if (fromLocation != null && toLocation != null) {
      polylineCoordinates = [fromLocation!, toLocation!];
    }
  }

  void startBikeAnimation() {
    if (polylineCoordinates.isEmpty || bikeMarker == null) return;

    const totalDuration = Duration(minutes: 5);
    final int steps = 500;

    final double stepLat =
        (polylineCoordinates[1].latitude - polylineCoordinates[0].latitude) /
            steps;
    final double stepLng =
        (polylineCoordinates[1].longitude - polylineCoordinates[0].longitude) /
            steps;

    int currentStep = 0;
    animationTimer?.cancel();

    animationTimer = Timer.periodic(
        Duration(milliseconds: totalDuration.inMilliseconds ~/ steps), (timer) {
      if (currentStep > steps) {
        timer.cancel();
        return;
      }

      LatLng newPos = LatLng(
        polylineCoordinates[0].latitude + stepLat * currentStep,
        polylineCoordinates[0].longitude + stepLng * currentStep,
      );

      bikeMarker = bikeMarker!.copyWith(positionParam: newPos);
      currentStep++;
      notifyListeners();
    });
  }

  void setMapController(GoogleMapController controller) {
    mapController = controller;
    notifyListeners();
  }

  @override
  void dispose() {
    animationTimer?.cancel();
    super.dispose();
  }
}