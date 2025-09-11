import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';

// Data Models
class Alert {
  final String alertId;
  final String typeOfHazard;
  final String description;
  final String severity; // e.g., 'low', 'medium', 'high'
  final Location location;

  Alert({
    required this.alertId,
    required this.typeOfHazard,
    required this.location,
    required this.severity,
    required this.description,
  });
}

// Dummy Alert Data
final List<Alert> _inMemoryAlerts = [
  Alert(
    alertId: 'A1',
    typeOfHazard: 'Oil Spill',
    location: Location(
      latitude: 34.0522,
      longitude: -118.2437,
      timestamp: DateTime.now(),
    ),
    severity: 'high',
    description: 'Large oil slick detected, threatening marine life.',
  ),
  Alert(
    alertId: 'A2',
    typeOfHazard: 'Dangerous Currents',
    location: Location(
      latitude: 40.7128,
      longitude: -74.0060,
      timestamp: DateTime.now(),
    ),
    severity: 'medium',
    description:
        'Strong rip currents reported. Swimmers advised to be cautious.',
  ),
  Alert(
    alertId: 'A3',
    typeOfHazard: 'Marine Debris',
    location: Location(
      latitude: 19.0760,
      longitude: 72.8777,
      timestamp: DateTime.now(),
    ),
    severity: 'low',
    description: 'A large patch of floating plastic debris was sighted.',
  ),
  Alert(
    alertId: 'A4',
    typeOfHazard: 'Jellyfish Swarm',
    location: Location(
      latitude: 25.7617,
      longitude: -80.1918,
      timestamp: DateTime.now(),
    ),
    severity: 'high',
    description:
        'A large swarm of venomous jellyfish has moved closer to shore.',
  ),
  Alert(
    alertId: 'A5',
    typeOfHazard: 'Water Quality',
    location: Location(
      latitude: 43.8563,
      longitude: -79.3370,
      timestamp: DateTime.now(),
    ),
    severity: 'medium',
    description:
        'Increased algae bloom reported. Avoid swimming in affected areas.',
  ),
  Alert(
    alertId: 'A6',
    typeOfHazard: 'Fishing Vessel Distress',
    location: Location(
      latitude: 53.0000,
      longitude: -30.0000,
      timestamp: DateTime.now(),
    ),
    severity: 'high',
    description:
        'Vessel sending out a distress signal. Search and rescue underway.',
  ),
  Alert(
    alertId: 'A7',
    typeOfHazard: 'Coastal Erosion',
    location: Location(
      latitude: 33.9983,
      longitude: -118.4907,
      timestamp: DateTime.now(),
    ),
    severity: 'low',
    description: 'Noticeable coastal erosion due to high tide and wind.',
  ),
];

class AlertsProvider with ChangeNotifier {
  List<Alert> _alerts = [];
  bool _isLoading = false;
  // Map to cache geocoded location names to avoid repeated network calls
  Map<String, String> _cachedLocationNames = {};

  List<Alert> get alerts => _alerts;
  bool get isLoading => _isLoading;

  AlertsProvider() {
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    _isLoading = true;
    notifyListeners();
    // Simulate a network call
    await Future.delayed(const Duration(milliseconds: 500));
    _alerts = _inMemoryAlerts;
    _isLoading = false;
    notifyListeners();
  }

  // Method to get a location name, checking the cache first
  Future<String> fetchLocationName(String alertId, Location location) async {
    if (_cachedLocationNames.containsKey(alertId)) {
      return _cachedLocationNames[alertId]!;
    }

    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final locationName = '${placemark.locality}, ${placemark.country}';
        _cachedLocationNames[alertId] = locationName; // Cache the result
        return locationName;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error geocoding location: $e");
      }
    }
    return "Location: Unknown";
  }

  void addAlert(Alert newAlert) {
    _alerts.insert(0, newAlert);
    notifyListeners();
  }
}
