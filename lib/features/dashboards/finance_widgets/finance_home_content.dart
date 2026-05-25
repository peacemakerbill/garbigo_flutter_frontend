import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';

class FinanceHomeContent extends ConsumerWidget {
  const FinanceHomeContent({super.key});

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
          // ==================== HERO SECTION ====================
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
                  'Welcome back, ${fullName.isNotEmpty ? fullName : "Finance Team"} 👋',
                  style: TextStyle(
                    fontSize: isMobile ? 26 : 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay on top of billing, payments & financial health',
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

          // ==================== KEY METRICS ====================
          const Text(
            'Key Metrics',
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
                childAspectRatio: 1.75,
                children: const [
                  _MetricCard(
                    title: 'Total Revenue',
                    value: 'KSh 4.28M',
                    subtitle: 'This Month',
                    icon: Icons.currency_exchange,
                    color: Color(0xFF22C55E),
                    trend: '+14%',
                  ),
                  _MetricCard(
                    title: 'Outstanding',
                    value: 'KSh 892K',
                    subtitle: '12 Invoices',
                    icon: Icons.warning_amber_rounded,
                    color: Color(0xFFF59E0B),
                    trend: '-8%',
                  ),
                  _MetricCard(
                    title: 'Payments Received',
                    value: 'KSh 3.39M',
                    subtitle: 'This Month',
                    icon: Icons.payments_outlined,
                    color: Color(0xFF3B82F6),
                    trend: '+22%',
                  ),
                  _MetricCard(
                    title: 'Avg Collection Days',
                    value: '6.4',
                    subtitle: 'Days',
                    icon: Icons.timer_outlined,
                    color: Color(0xFF8B5CF6),
                    trend: '-2 days',
                  ),
                ],
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
                childAspectRatio: 2.4,
                children: const [
                  _QuickActionCard(
                    icon: Icons.add_circle_outline,
                    title: 'Create Invoice',
                    color: Colors.green,
                  ),
                  _QuickActionCard(
                    icon: Icons.receipt_long,
                    title: 'View All Invoices',
                    color: Colors.blue,
                  ),
                  _QuickActionCard(
                    icon: Icons.payment,
                    title: 'Record Payment',
                    color: Colors.purple,
                  ),
                  _QuickActionCard(
                    icon: Icons.analytics_outlined,
                    title: 'Generate Report',
                    color: Colors.orange,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 40),

          // ==================== RECENT TRANSACTIONS ====================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward),
                label: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF22C55E),
                    child: Icon(Icons.arrow_downward, color: Colors.white),
                  ),
                  title: Text('Payment from Client ${index + 1}'),
                  subtitle: Text('${DateTime.now().subtract(Duration(days: index)).toString().substring(0, 10)} • M-Pesa'),
                  trailing: const Text(
                    'KSh 3,250',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==================== METRIC CARD ====================
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String trend;

  const _MetricCard({
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
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            trend,
            style: TextStyle(
              color: trend.startsWith('+') ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== QUICK ACTION CARD ====================
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _QuickActionCard({
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
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}