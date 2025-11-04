class LocationModel {
  final double latitude;
  final double longitude;
  final String? name;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.name,
  });

  factory LocationModel.fromLatLng(double lat, double lng, {String? name}) {
    return LocationModel(latitude: lat, longitude: lng, name: name);
  }

  @override
  String toString() {
    return name ?? '($latitude, $longitude)';
  }
}
