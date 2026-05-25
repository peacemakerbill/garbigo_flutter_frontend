import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';

class OperationsHomeContent extends ConsumerWidget {
  const OperationsHomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).user;
    final fullName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================== HERO ====================
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 24 : 32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF22C55E), Color(0xFF15803D)],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.25),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${fullName.isNotEmpty ? fullName : "Operations Team"} 👋',
                  style: TextStyle(
                    fontSize: isMobile ? 26 : 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Managing routes • Optimizing collections • Driving efficiency',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isMobile ? 15 : 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ==================== LIVE STATS ====================
          const Text(
            'Live Operations Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 1100 ? 4 : constraints.maxWidth > 700 ? 2 : 1;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.65,
                children: const [
                  _LiveMetricCard(
                    title: 'Today\'s Collections',
                    value: '184',
                    subtitle: 'Tonnes Collected',
                    icon: Icons.local_shipping,
                    color: Color(0xFF22C55E),
                    trend: '↑ 12%',
                  ),
                  _LiveMetricCard(
                    title: 'Active Routes',
                    value: '23',
                    subtitle: '8 In Progress',
                    icon: Icons.route,
                    color: Color(0xFF3B82F6),
                    trend: 'On Track',
                  ),
                  _LiveMetricCard(
                    title: 'Fleet Utilization',
                    value: '87%',
                    subtitle: 'This Shift',
                    icon: Icons.directions_bus,
                    color: Color(0xFF8B5CF6),
                    trend: '↑ 5%',
                  ),
                  _LiveMetricCard(
                    title: 'Avg Completion',
                    value: '94%',
                    subtitle: 'Today',
                    icon: Icons.check_circle_outline,
                    color: Color(0xFF22C55E),
                    trend: '↑ 3%',
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 40),

          // ==================== ACTIVE ROUTES & PRIORITY (FIXED) ====================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Routes & Priorities',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (!isMobile)
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('View All Routes'),
                ),
            ],
          ),
          if (isMobile)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward),
                label: const Text('View All Routes'),
              ),
            ),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (context, index) {
              final isHigh = index < 2;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  leading: CircleAvatar(
                    backgroundColor: isHigh ? Colors.orange.shade100 : Colors.blue.shade100,
                    child: Icon(
                      isHigh ? Icons.warning_amber_rounded : Icons.route,
                      color: isHigh ? Colors.orange : Colors.blue,
                    ),
                  ),
                  title: Text('Route #R-${100 + index} - ${isHigh ? "Downtown Central" : "Industrial Zone"}'),
                  subtitle: Text('Vehicle ${index + 1} • ${isHigh ? "Delayed by 25 min" : "On Schedule"}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isHigh ? Colors.orange : Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isHigh ? 'DELAYED' : 'ON TIME',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 40),

          // ==================== QUICK ACTIONS ====================
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 900 ? 4 : constraints.maxWidth > 600 ? 2 : 1;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.2,
                children: const [
                  _ActionCard(icon: Icons.add_road, title: 'New Route', color: Colors.blue),
                  _ActionCard(icon: Icons.schedule, title: 'Schedule Pickup', color: Colors.green),
                  _ActionCard(icon: Icons.local_shipping, title: 'Assign Vehicle', color: Colors.purple),
                  _ActionCard(icon: Icons.analytics, title: 'Generate Report', color: Colors.orange),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==================== LIVE METRIC CARD & ACTION CARD (unchanged) ====================
class _LiveMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String trend;

  const _LiveMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(
                trend,
                style: TextStyle(
                  color: trend.startsWith('↑') || trend == 'On Track' || trend == 'All Good'
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1),
          ),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade100),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}