import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

import 'package:garbigo_frontend/features/location/providers/live_location_provider.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';

class CollectorHomeContent extends ConsumerWidget {
  const CollectorHomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).user;
    final locationState = ref.watch(liveLocationProvider);
    final fullName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(liveLocationProvider),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24,
          vertical: isMobile ? 16 : 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? 24 : 32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF22C55E), Color(0xFF15803D)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${fullName.isNotEmpty ? fullName : "Collector"} 👋',
                    style: TextStyle(
                      fontSize: isMobile ? 26 : 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ready to make the city cleaner?',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isMobile ? 15 : 17,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Live Location Map
            const Text(
              'Live Location',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            Container(
              height: isMobile ? 260 : 340,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: _buildMap(locationState),
              ),
            ),

            const SizedBox(height: 12),
            _LiveStatusCard(locationState: locationState),

            const SizedBox(height: 32),

            // Stats Overview
            const Text(
              'Today\'s Overview',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 1100
                    ? 4
                    : constraints.maxWidth > 700
                    ? 2
                    : 1;

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: crossAxisCount == 1 ? 2.8 : 1.7,
                  children: const [
                    _StatCard(title: 'Active Jobs', value: '3', icon: Icons.work, color: Color(0xFF22C55E)),
                    _StatCard(title: 'Waste Collected', value: '87 kg', icon: Icons.recycling, color: Color(0xFF3B82F6)),
                    _StatCard(title: 'Earnings Today', value: 'KSh 2,450', icon: Icons.currency_exchange, color: Color(0xFF8B5CF6)),
                    _StatCard(title: 'Rating', value: '4.9 ★', icon: Icons.star, color: Color(0xFFF59E0B)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(dynamic locationState) {
    if (locationState.currentPosition == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Getting your location...'),
          ],
        ),
      );
    }

    return FlutterMap(
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
          tileProvider: CancellableNetworkTileProvider(),
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(
                locationState.currentPosition!.latitude,
                locationState.currentPosition!.longitude,
              ),
              width: 60,
              height: 60,
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 60,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LiveStatusCard extends StatelessWidget {
  final dynamic locationState;

  const _LiveStatusCard({required this.locationState});

  @override
  Widget build(BuildContext context) {
    final isTracking = locationState.isTracking ?? false;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isTracking ? Icons.location_on : Icons.location_off,
              color: isTracking ? Colors.green : Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTracking ? 'Live Tracking Active' : 'Location Tracking Off',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (locationState.currentPosition != null)
                    Text(
                      'Accuracy: ±${locationState.currentPosition!.accuracy.toStringAsFixed(0)}m',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                ],
              ),
            ),
            Switch(
              value: isTracking,
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}