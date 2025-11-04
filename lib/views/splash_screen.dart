import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkNetworkAndLocation();
  }

  Future<void> checkNetworkAndLocation() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      await showAlert(
          "No Internet", "Please turn ON your internet connection.");
      return checkNetworkAndLocation();
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await showAlert(
          "Location Disabled", "Please enable your device location.");
      return checkNetworkAndLocation();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await showAlert(
            "Permission Denied", "Location permission is required.");
        return checkNetworkAndLocation();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await showAlert("Permission Denied",
          "Location permission permanently denied. Enable from settings.");
      return;
    }

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  Future<void> showAlert(String title, String message) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Checking network & location...",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
