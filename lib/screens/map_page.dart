import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:oceo/providers/alerts_provider.dart';
import 'package:provider/provider.dart';

class MapPage extends StatelessWidget {
  final Future<LatLng> userLocationFuture;

  const MapPage({super.key, required this.userLocationFuture});

  static const LatLng _defaultLocation = LatLng(28.7041, 77.1025); // Fallback

  Set<Marker> _getAlertMarkers(List<Alert> alerts, LatLng? userLocation) {
    Set<Marker> markers = {};
    if (userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: userLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'My Location'),
        ),
      );
    }

    for (var alert in alerts) {
      BitmapDescriptor icon;
      switch (alert.severity.toLowerCase()) {
        case 'high':
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
          break;
        case 'medium':
          icon = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          );
          break;
        default:
          icon = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          );
      }
      markers.add(
        Marker(
          markerId: MarkerId(alert.alertId),
          position: LatLng(
            alert.locationCoordinates.latitude,
            alert.locationCoordinates.longitude,
          ),
          icon: icon,
          infoWindow: InfoWindow(
            title: alert.hazard,
            snippet: alert.description,
          ),
        ),
      );
    }
    return markers;
  }

  // UPDATED: Replaced the dark overlay with a cleaner "expand" icon
  Widget _buildMiniMap(
    BuildContext context,
    LatLng initialCenter,
    LatLng userLocation, // Pass the user location for the full-screen map
    Set<Marker> markers,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenMap(
              initialCenter: initialCenter,
              userLocation: userLocation, // Pass the location
              markers: markers,
            ),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: Colors.blueAccent.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: AbsorbPointer(
                // Makes the map underneath not interactive
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: initialCenter,
                    zoom: 12.0,
                  ),
                  markers: markers,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  scrollGesturesEnabled: false,
                  zoomGesturesEnabled: false,
                ),
              ),
            ),
          ),
          // This is the new "expand" icon
          Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.fullscreen, color: Colors.blueAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alerts Legend:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildLegendItem(Colors.red, 'High Severity'),
          _buildLegendItem(Colors.orange, 'Medium Severity'),
          _buildLegendItem(Colors.green, 'Low Severity'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LatLng>(
      future: userLocationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SpinKitWaveSpinner(color: Colors.blueAccent, size: 50.0),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final LatLng userLocation = snapshot.data ?? _defaultLocation;
        return Consumer<AlertsProvider>(
          builder: (context, alertsProvider, child) {
            final alerts = alertsProvider.alerts;
            final markers = _getAlertMarkers(alerts, userLocation);
            final initialCenter = userLocation;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Live Alerts Map',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMiniMap(
                      context,
                      initialCenter,
                      userLocation,
                      markers,
                    ),
                    const SizedBox(height: 16),
                    _buildLegend(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class FullScreenMap extends StatefulWidget {
  final LatLng initialCenter;
  final LatLng userLocation; // UPDATED: Pass the user's location
  final Set<Marker> markers;

  const FullScreenMap({
    super.key,
    required this.initialCenter,
    required this.userLocation,
    required this.markers,
  });

  @override
  State<FullScreenMap> createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<FullScreenMap> {
  final Completer<GoogleMapController> _controller = Completer();

  void _zoomIn() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.zoomOut());
  }

  // NEW: Method to animate the camera back to the user's location
  void _centerOnMyLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: widget.userLocation, zoom: 14.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text('Live Alerts Map'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: widget.initialCenter,
              zoom: 12.0,
            ),
            markers: widget.markers,
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false, // Hide default zoom buttons
          ),
          Positioned(
            bottom: 20,
            right: 16,
            child: Column(
              children: [
                // NEW: The "Center on My Location" button
                FloatingActionButton(
                  heroTag: 'centerButton',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent,
                  onPressed: _centerOnMyLocation,
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'zoomInButton',
                  mini: true,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  foregroundColor: Colors.blueAccent,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoomOutButton',
                  mini: true,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  foregroundColor: Colors.blueAccent,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
