import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:garbigo_frontend/features/location/providers/live_location_provider.dart';

class CollectorHomeContent extends ConsumerWidget {
  const CollectorHomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).user;
    final locationState = ref.watch(liveLocationProvider);
    final notifier = ref.read(liveLocationProvider.notifier);

    final width = MediaQuery.of(context).size.width;
    final isTiny = width < 360;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1000;

    final fullName =
    '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();

    double padding = isTiny
        ? 10
        : isMobile
        ? 14
        : isTablet
        ? 20
        : 28;

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(liveLocationProvider),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? 18 : 28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF22C55E), Color(0xFF15803D)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${fullName.isEmpty ? "Collector" : fullName} 👋',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: isTiny
                          ? 20
                          : isMobile
                          ? 24
                          : 34,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ready to make the city cleaner?',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isTiny ? 12 : 15,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 22 : 30),

            _sectionTitle('Live Location', isMobile),

            const SizedBox(height: 12),

            // MAP
            Container(
              height: isTiny
                  ? 220
                  : isMobile
                  ? 270
                  : 360,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: _buildMap(locationState),
              ),
            ),

            const SizedBox(height: 12),

            // LIVE STATUS
            Container(
              padding: EdgeInsets.all(isTiny ? 12 : 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: isTiny
                  ? Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        locationState.isTracking ?? false
                            ? Icons.location_on
                            : Icons.location_off,
                        color: locationState.isTracking ?? false
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          locationState.isTracking ?? false
                              ? 'Live Tracking Active'
                              : 'Location Tracking Off',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          locationState.currentPosition != null
                              ? 'Accuracy: ±${locationState.currentPosition!.accuracy.toStringAsFixed(0)}m'
                              : 'Location unavailable',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Switch(
                        value:
                        locationState.isTracking ?? false,
                        activeColor: Colors.green,
                        onChanged: (v) {
                          if (v) {
                            notifier
                                .requestPermissionAndStart();
                          } else {
                            notifier.stopTracking();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              )
                  : Row(
                children: [
                  Icon(
                    locationState.isTracking ?? false
                        ? Icons.location_on
                        : Icons.location_off,
                    color: locationState.isTracking ?? false
                        ? Colors.green
                        : Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          locationState.isTracking ?? false
                              ? 'Live Tracking Active'
                              : 'Location Tracking Off',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (locationState.currentPosition !=
                            null)
                          Text(
                            'Accuracy: ±${locationState.currentPosition!.accuracy.toStringAsFixed(0)}m',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Switch(
                    value:
                    locationState.isTracking ?? false,
                    activeColor: Colors.green,
                    onChanged: (v) {
                      if (v) {
                        notifier
                            .requestPermissionAndStart();
                      } else {
                        notifier.stopTracking();
                      }
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 24 : 32),

            _sectionTitle('Today\'s Overview', isMobile),

            const SizedBox(height: 16),

            _responsiveGrid(
              width,
              [
                _statCard(
                  title: 'Active Jobs',
                  value: '3',
                  icon: Icons.work,
                  color: const Color(0xFF22C55E),
                  tiny: isTiny,
                ),
                _statCard(
                  title: 'Waste Collected',
                  value: '87 kg',
                  icon: Icons.recycling,
                  color: const Color(0xFF3B82F6),
                  tiny: isTiny,
                ),
                _statCard(
                  title: 'Earnings Today',
                  value: 'KSh 2,450',
                  icon: Icons.currency_exchange,
                  color: const Color(0xFF8B5CF6),
                  tiny: isTiny,
                ),
                _statCard(
                  title: 'Rating',
                  value: '4.9 ★',
                  icon: Icons.star,
                  color: const Color(0xFFF59E0B),
                  tiny: isTiny,
                ),
              ],
              maxColumns: 4,
            ),

            SizedBox(height: isMobile ? 24 : 32),

            _sectionTitle('Upcoming Pickups', isMobile),

            const SizedBox(height: 16),

            SizedBox(
              height: isMobile ? 170 : 185,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _pickupCard(
                    width:
                    isTiny ? width * 0.82 : width < 600 ? 250 : 270,
                    client: 'Alice Wanjiku',
                    address: 'Westlands, Nairobi',
                    time: '2:30 PM',
                    waste: '18 kg Mixed',
                    tiny: isTiny,
                  ),
                  _pickupCard(
                    width:
                    isTiny ? width * 0.82 : width < 600 ? 250 : 270,
                    client: 'James Omondi',
                    address: 'Kilimani, Nairobi',
                    time: '4:00 PM',
                    waste: '12 kg Plastic',
                    tiny: isTiny,
                  ),
                  _pickupCard(
                    width:
                    isTiny ? width * 0.82 : width < 600 ? 250 : 270,
                    client: 'Grace Muthoni',
                    address: 'Lavington, Nairobi',
                    time: 'Tomorrow 9:00 AM',
                    waste: '25 kg Organic',
                    tiny: isTiny,
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 24 : 32),

            _sectionTitle('This Week\'s Performance', isMobile),

            const SizedBox(height: 16),

            _responsiveGrid(
              width,
              [
                _statCard(
                  title: 'Total Earnings',
                  value: 'KSh 14,820',
                  icon: Icons.currency_exchange,
                  color: const Color(0xFF10B981),
                  tiny: isTiny,
                ),
                _statCard(
                  title: 'Collections',
                  value: '18',
                  icon: Icons.local_shipping,
                  color: const Color(0xFF3B82F6),
                  tiny: isTiny,
                ),
                _statCard(
                  title: 'CO₂ Saved',
                  value: '248 kg',
                  icon: Icons.eco,
                  color: const Color(0xFF22C55E),
                  tiny: isTiny,
                ),
              ],
              maxColumns: 3,
            ),

            SizedBox(height: isMobile ? 28 : 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(dynamic state) {
    if (state.currentPosition == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text('Getting your location...'),
          ],
        ),
      );
    }

    final lat = state.currentPosition!.latitude;
    final lng = state.currentPosition!.longitude;

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(lat, lng),
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
              point: LatLng(lat, lng),
              width: 48,
              height: 48,
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 48,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, bool mobile) {
    return Text(
      title,
      style: TextStyle(
        fontSize: mobile ? 20 : 24,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _responsiveGrid(
      double width,
      List<Widget> children, {
        required int maxColumns,
      }) {
    int columns = 1;

    if (width >= 1200) {
      columns = maxColumns;
    } else if (width >= 700) {
      columns = 2;
    }

    return GridView.builder(
      shrinkWrap: true,
      itemCount: children.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: columns == 1 ? 2.1 : 1.5,
      ),
      itemBuilder: (_, i) => children[i],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool tiny,
  }) {
    return Container(
      padding: EdgeInsets.all(tiny ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(tiny ? 8 : 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: tiny ? 22 : 28,
            ),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: tiny ? 22 : 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: tiny ? 12 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pickupCard({
    required double width,
    required String client,
    required String address,
    required String time,
    required String waste,
    required bool tiny,
  }) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 14),
      padding: EdgeInsets.all(tiny ? 14 : 16),
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
              CircleAvatar(
                radius: tiny ? 18 : 20,
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: tiny ? 18 : 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  client,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: tiny ? 13 : 15,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: tiny ? 10 : 14),
          Text(
            address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: tiny ? 12 : 13,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      time,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: tiny ? 12 : 14,
                      ),
                    ),
                    Text(
                      waste,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: tiny ? 11 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: tiny ? 14 : 16,
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
}