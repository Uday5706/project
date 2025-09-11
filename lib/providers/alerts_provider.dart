import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// A simple model for geographic coordinates
class LocationCoordinates {
  final double latitude;
  final double longitude;

  LocationCoordinates({required this.latitude, required this.longitude});

  factory LocationCoordinates.fromMap(Map<String, dynamic> map) {
    return LocationCoordinates(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// Data Model for a single Alert
class Alert {
  final String alertId;
  final String hazard;
  final String description;
  final String severity;
  final LocationCoordinates locationCoordinates; // renamed
  final String location; // plain string name
  final DateTime timestamp;

  Alert({
    required this.alertId,
    required this.hazard,
    required this.description,
    required this.severity,
    required this.locationCoordinates,
    required this.location,
    required this.timestamp,
  });

  factory Alert.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Alert(
      alertId: doc.id,
      hazard: data['hazard'] ?? 'Unknown Hazard',
      description: data['description'] ?? '',
      severity: data['severity'] ?? 'low',
      locationCoordinates: LocationCoordinates.fromMap(
        data['location_coordinates'] ?? {},
      ),
      location: data['location'] ?? 'Unknown Location',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class AlertsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Alert> _alerts = [];
  bool _isLoading = true;

  List<Alert> get alerts => _alerts;
  bool get isLoading => _isLoading;

  AlertsProvider() {
    _listenToAlerts();
  }

  int calculateSafetyScore(LatLng userLocation) {
    if (alerts.isEmpty) return 100; // fully safe if no alerts

    double dangerIndex = 0.0;

    for (final alert in alerts) {
      final distanceMeters = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        alert.locationCoordinates.latitude,
        alert.locationCoordinates.longitude,
      );

      final distanceKm = distanceMeters / 1000.0;

      // Severity weights
      final severityWeight = switch (alert.severity.toLowerCase()) {
        'high' => 1.0,
        'medium' => 0.5,
        'low' => 0.2,
        _ => 0.2,
      };

      // Contribution shrinks with distance
      final contribution = severityWeight / (distanceKm + 1);
      dangerIndex += contribution;
    }

    // Scale to 0–100 (tune 20.0 factor as sensitivity)
    final scaledDanger = (dangerIndex * 20.0).clamp(0, 100);
    final safetyScore = (100 - scaledDanger).toInt();

    return safetyScore;
  }

  void _listenToAlerts() {
    _firestore
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _alerts = snapshot.docs
                .map((doc) => Alert.fromFirestore(doc))
                .toList();
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            if (kDebugMode) {
              print("Error listening to alerts: $error");
            }
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  // Future<void> addRandomNearbyAlerts() async {
  //   final alertsCollection = _firestore.collection('alerts');
  //   final batch = _firestore.batch();
  //   final random = Random();
  //
  //   const double baseLat = 28.7041;
  //   const double baseLng = 77.1025;
  //
  //   final List<Map<String, dynamic>> hazardPool = [
  //     {
  //       'hazard': 'Poor Water Quality',
  //       'description':
  //           'High levels of pollutants detected in the Yamuna River.',
  //     },
  //     {
  //       'hazard': 'Industrial Spill',
  //       'description': 'Chemical spill reported near the Wazirabad barrage.',
  //     },
  //     {
  //       'hazard': 'Algae Bloom',
  //       'description': 'Unusual algae bloom affecting local water bodies.',
  //     },
  //     {
  //       'hazard': 'Flash Flood Warning',
  //       'description':
  //           'Risk of sudden flooding in low-lying areas near the river.',
  //     },
  //   ];
  //
  //   final severities = ['high', 'medium', 'low'];
  //
  //   for (int i = 0; i < 5; i++) {
  //     final hazardData = hazardPool[random.nextInt(hazardPool.length)];
  //     final severity = severities[random.nextInt(severities.length)];
  //
  //     final latOffset = (random.nextDouble() - 0.5) * 0.4;
  //     final lngOffset = (random.nextDouble() - 0.5) * 0.4;
  //
  //     final alertLocationCoordinates = {
  //       'latitude': baseLat + latOffset,
  //       'longitude': baseLng + lngOffset,
  //     };
  //
  //     final alertData = {
  //       'hazard': hazardData['hazard'],
  //       'description': hazardData['description'],
  //       'severity': severity,
  //       'location': 'Near Delhi, India', // renamed
  //       'location_coordinates': alertLocationCoordinates, // renamed
  //       'timestamp': Timestamp.now(),
  //     };
  //
  //     final docRef = alertsCollection.doc();
  //     batch.set(docRef, alertData);
  //   }
  //
  //   try {
  //     await batch.commit();
  //     debugPrint("✅ Successfully added 5 random nearby alerts!");
  //   } catch (e) {
  //     debugPrint("❌ Error adding random alerts: $e");
  //   }
  // }
}
