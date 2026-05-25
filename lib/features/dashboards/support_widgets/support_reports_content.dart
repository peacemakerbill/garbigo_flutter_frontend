import 'package:flutter/material.dart';

class SupportReportsContent extends StatelessWidget {
  const SupportReportsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Support Reports',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Performance metrics and customer satisfaction',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.7,
            children: const [
              _ReportCard(title: 'Tickets Resolved', value: '187', trend: 'This Month'),
              _ReportCard(title: 'Avg Resolution Time', value: '4.8 hrs', trend: '↓ 1.2 hrs'),
              _ReportCard(title: 'Customer Satisfaction', value: '4.7/5', trend: '↑ 0.3'),
              _ReportCard(title: 'Active Agents', value: '12', trend: 'Online'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;

  const _ReportCard({required this.title, required this.value, required this.trend});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, color: Colors.grey)),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            Text(trend, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}