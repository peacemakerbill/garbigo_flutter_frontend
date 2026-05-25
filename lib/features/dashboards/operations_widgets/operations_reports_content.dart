import 'package:flutter/material.dart';

class OperationsReportsContent extends StatelessWidget {
  const OperationsReportsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reports & Analytics', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Performance insights and business reports', style: TextStyle(fontSize: 16, color: Color(0xFF757575))),
          const SizedBox(height: 32),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: const [
              _ReportCard(title: 'Collection Efficiency', value: '94%', trend: '+5%'),
              _ReportCard(title: 'Total Waste Collected', value: '2.8T', trend: 'This Month'),
              _ReportCard(title: 'Active Collectors', value: '47', trend: 'Online'),
              _ReportCard(title: 'Avg Response Time', value: '18 min', trend: '-3 min'),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 15)),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            Text(trend, style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}