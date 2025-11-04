import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../viewmodels/map_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bike Tracker Map')),
      body: const MapWidget(),
    );
  }
}

/// ===================
/// MapWidget
/// ===================
class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late MapViewModel mapVM;

  @override
  void initState() {
    super.initState();
    mapVM = Provider.of<MapViewModel>(context, listen: false);
    _setCurrentLocation();
  }

  Future<void> _setCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    mapVM.setFromLocation(LatLng(position.latitude, position.longitude));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (_, mapVM, __) {
        Set<Marker> allMarkers = {};
        if (mapVM.fromMarker != null) allMarkers.add(mapVM.fromMarker!);
        if (mapVM.toMarker != null) allMarkers.add(mapVM.toMarker!);
        if (mapVM.bikeMarker != null) allMarkers.add(mapVM.bikeMarker!);

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: mapVM.fromLocation ?? const LatLng(9.9252, 78.1198),
            zoom: 14,
          ),
          markers: allMarkers,
          polylines: {
            if (mapVM.polylineCoordinates.isNotEmpty)
              Polyline(
                polylineId: const PolylineId("route"),
                points: mapVM.polylineCoordinates,
                color: Colors.blue,
                width: 5,
              ),
          },
          onMapCreated: (controller) => mapVM.setMapController(controller),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onTap: (latLng) {
            // Set To location wherever user taps
            mapVM.setToLocation(latLng);
          },
        );
      },
    );
  }
}
