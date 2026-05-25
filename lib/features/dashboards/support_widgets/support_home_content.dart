import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';

class SupportHomeContent extends ConsumerWidget {
  const SupportHomeContent({super.key});

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
                  'Welcome back, ${fullName.isNotEmpty ? fullName : "Support Team"} 👋',
                  style: TextStyle(
                    fontSize: isMobile ? 26 : 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Helping customers • Resolving issues • Building trust',
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
            'Live Support Overview',
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
                    title: 'Open Tickets',
                    value: '27',
                    subtitle: '4 High Priority',
                    icon: Icons.support_agent_rounded,
                    color: Color(0xFFEF4444),
                    trend: '↑ 3',
                  ),
                  _LiveMetricCard(
                    title: 'Avg Response',
                    value: '38 min',
                    subtitle: 'Today',
                    icon: Icons.timer_outlined,
                    color: Color(0xFF3B82F6),
                    trend: '↓ 12 min',
                  ),
                  _LiveMetricCard(
                    title: 'Resolution Rate',
                    value: '91%',
                    subtitle: 'This Week',
                    icon: Icons.check_circle_outline,
                    color: Color(0xFF22C55E),
                    trend: '↑ 4%',
                  ),
                  _LiveMetricCard(
                    title: 'Active Agents',
                    value: '14',
                    subtitle: '8 Online',
                    icon: Icons.people_outline,
                    color: Color(0xFF8B5CF6),
                    trend: 'All Good',
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 40),

          // ==================== QUEUE & PRIORITY ====================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Priority Queue',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward),
                label: const Text('View All Tickets'),
              ),
            ],
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
                    backgroundColor: isHigh ? Colors.red.shade100 : Colors.orange.shade100,
                    child: Icon(
                      isHigh ? Icons.priority_high : Icons.access_time,
                      color: isHigh ? Colors.red : Colors.orange,
                    ),
                  ),
                  title: Text('Ticket #SUP-10${index} - ${isHigh ? "Payment Failed" : "Collection Delay"}'),
                  subtitle: Text('Client ${index + 1} • ${isHigh ? "2 hours ago" : "Yesterday"}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isHigh ? Colors.red : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isHigh ? 'HIGH' : 'MEDIUM',
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
                  _ActionCard(icon: Icons.add_comment, title: 'New Ticket', color: Colors.blue),
                  _ActionCard(icon: Icons.chat_bubble_outline, title: 'Live Chat', color: Colors.green),
                  _ActionCard(icon: Icons.call, title: 'Call Customer', color: Colors.purple),
                  _ActionCard(icon: Icons.article_outlined, title: 'Create FAQ', color: Colors.orange),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==================== LIVE METRIC CARD ====================
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
                  color: trend.startsWith('↑') || trend == 'All Good' ? Colors.green : Colors.red,
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

// ==================== ACTION CARD ====================
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