import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';
import 'package:garbigo_frontend/features/location/providers/live_location_provider.dart';

class CollectorDashboardScreen extends ConsumerStatefulWidget {
  const CollectorDashboardScreen({super.key});

  @override
  ConsumerState<CollectorDashboardScreen> createState() => _CollectorDashboardScreenState();
}

class _CollectorDashboardScreenState extends ConsumerState<CollectorDashboardScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(liveLocationProvider);
    final authNotifier = ref.read(authProvider.notifier);

    // Auto-start tracking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!locationState.permissionGranted) {
        ref.read(liveLocationProvider.notifier).requestPermissionAndStart();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collector Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.location_on, color: locationState.isTracking ? Colors.green : Colors.grey),
            onPressed: () {
              if (locationState.isTracking) {
                Helpers.showToast('Live tracking active');
              } else {
                ref.read(liveLocationProvider.notifier).requestPermissionAndStart();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Helpers.showLogoutDialog(context, () {
              ref.read(liveLocationProvider.notifier).stopTracking();
              authNotifier.logout();
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          // Live Location Status Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.my_location, color: locationState.isTracking ? Colors.green : Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          locationState.isTracking ? 'Live Tracking Active' : 'Location Off',
                          style: TextStyle(fontWeight: FontWeight.bold, color: locationState.isTracking ? Colors.green : Colors.orange),
                        ),
                      ],
                    ),
                    if (locationState.currentPosition != null) ...[
                      const SizedBox(height: 8),
                      Text('Lat: ${locationState.currentPosition!.latitude.toStringAsFixed(6)}'),
                      Text('Lng: ${locationState.currentPosition!.longitude.toStringAsFixed(6)}'),
                      Text('Accuracy: ±${locationState.currentPosition!.accuracy.toStringAsFixed(1)}m'),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Google Map
          Expanded(
            child: locationState.currentPosition == null
                ? const Center(child: Text('Waiting for location...'))
                : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  locationState.currentPosition!.latitude,
                  locationState.currentPosition!.longitude,
                ),
                initialZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.garbigo.frontend',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        locationState.currentPosition!.latitude,
                        locationState.currentPosition!.longitude,
                      ),
                      width: 48,
                      height: 48,
                      child: const Tooltip(
                        message: 'My Location',
                        child: Icon(
                          Icons.location_pin,
                          color: Colors.green,
                          size: 48,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/profile'),
        child: const Icon(Icons.person),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}