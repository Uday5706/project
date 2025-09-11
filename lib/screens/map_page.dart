import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:oceo/providers/alerts_provider.dart';
import 'package:provider/provider.dart';

class MapPage extends StatelessWidget {
  final Future<LatLng> userLocationFuture;

  const MapPage({super.key, required this.userLocationFuture});

  static const LatLng _defaultLocation = LatLng(37.422, -122.084);

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
      switch (alert.severity) {
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
          position: LatLng(alert.location.latitude, alert.location.longitude),
          icon: icon,
          infoWindow: InfoWindow(title: alert.typeOfHazard),
        ),
      );
    }
    return markers;
  }

  Widget _buildMap(LatLng initialCenter, Set<Marker> markers, bool fullScreen) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(target: initialCenter, zoom: 12.0),
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
    );
  }

  Widget _buildMiniMap(
    BuildContext context,
    LatLng initialCenter,
    Set<Marker> markers,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FullScreenMap(initialCenter: initialCenter, markers: markers),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: Colors.blueAccent, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: _buildMap(initialCenter, markers, false),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.black.withOpacity(0.3),
              ),
              child: const Center(
                child: Text(
                  'Tap to view full map',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
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
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
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
                      _buildMiniMap(context, initialCenter, markers),
                      const SizedBox(height: 16),
                      _buildLegend(),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class FullScreenMap extends StatefulWidget {
  final LatLng initialCenter;
  final Set<Marker> markers;

  const FullScreenMap({
    super.key,
    required this.initialCenter,
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
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoomInButton',
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoomOutButton',
                  mini: true,
                  backgroundColor: Colors.white,
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
