import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class PlacesService {
  final FlutterGooglePlacesSdk places;

  PlacesService(String apiKey) : places = FlutterGooglePlacesSdk(apiKey);

  // Get autocomplete suggestions
  Future<List<AutocompletePrediction>> getSuggestions(String input) async {
    final result = await places.findAutocompletePredictions(input);
    return result.predictions;
  }

  // Get LatLng from Place ID
  Future<gmaps.LatLng> getPlaceLatLng(String placeId) async {
    final place = await places.fetchPlace(
      placeId,
      fields: [PlaceField.Name, PlaceField.Location], // new API
    );

    final loc = place.place?.latLng;
    if (loc == null) throw Exception("Location not found");

    return gmaps.LatLng(loc.lat, loc.lng);
  }
}
