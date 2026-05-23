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
    final locationNotifier = ref.read(liveLocationProvider.notifier);

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
            _LiveStatusCard(
              locationState: locationState,
              onToggle: (value) {
                if (value) {
                  locationNotifier.requestPermissionAndStart();
                } else {
                  locationNotifier.stopTracking();
                }
              },
            ),

            const SizedBox(height: 32),

            // Today's Overview
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

            const SizedBox(height: 32),

            // ==================== NEW SECTIONS ====================

            // Upcoming Pickups
            const Text(
              'Upcoming Pickups',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 165,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _UpcomingPickupCard(
                    client: 'Alice Wanjiku',
                    address: 'Westlands, Nairobi',
                    time: '2:30 PM',
                    waste: '18 kg Mixed',
                  ),
                  _UpcomingPickupCard(
                    client: 'James Omondi',
                    address: 'Kilimani, Nairobi',
                    time: '4:00 PM',
                    waste: '12 kg Plastic',
                  ),
                  _UpcomingPickupCard(
                    client: 'Grace Muthoni',
                    address: 'Lavington, Nairobi',
                    time: 'Tomorrow 9:00 AM',
                    waste: '25 kg Organic',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // This Week's Performance
            const Text(
              'This Week\'s Performance',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 900 ? 3 : 1;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: crossAxisCount == 1 ? 2.6 : 1.85,
                  children: const [
                    _StatCard(
                      title: 'Total Earnings',
                      value: 'KSh 14,820',
                      icon: Icons.currency_exchange,
                      color: Color(0xFF10B981),
                    ),
                    _StatCard(
                      title: 'Collections',
                      value: '18',
                      icon: Icons.local_shipping,
                      color: Color(0xFF3B82F6),
                    ),
                    _StatCard(
                      title: 'CO₂ Saved',
                      value: '248 kg',
                      icon: Icons.eco,
                      color: Color(0xFF22C55E),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),
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

// ==================== LIVE STATUS CARD ====================
class _LiveStatusCard extends StatelessWidget {
  final dynamic locationState;
  final ValueChanged<bool> onToggle;

  const _LiveStatusCard({
    required this.locationState,
    required this.onToggle,
  });

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
              activeColor: Colors.green,
              onChanged: onToggle,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== STAT CARD ====================
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

// ==================== UPCOMING PICKUP CARD ====================
class _UpcomingPickupCard extends StatelessWidget {
  final String client;
  final String address;
  final String time;
  final String waste;

  const _UpcomingPickupCard({
    required this.client,
    required this.address,
    required this.time,
    required this.waste,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  client,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(address, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(time, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(waste, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.green),
            ],
          ),
        ],
      ),
    );
  }
}