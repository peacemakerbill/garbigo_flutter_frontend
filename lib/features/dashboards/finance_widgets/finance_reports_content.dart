import 'package:flutter/material.dart';

class FinanceReportsContent extends StatelessWidget {
  const FinanceReportsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Reports',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Revenue, expenses, and performance analytics',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: const [
              _ReportCard(title: 'Monthly Revenue', value: 'KSh 2.84M', trend: '+12%'),
              _ReportCard(title: 'Collection Rate', value: '92%', trend: '+3%'),
              _ReportCard(title: 'Outstanding Balance', value: 'KSh 487K', trend: '12 invoices'),
              _ReportCard(title: 'Avg Invoice Value', value: 'KSh 3,240', trend: 'Stable'),
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

  const _ReportCard({
    required this.title,
    required this.value,
    required this.trend,
  });

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
            Text(trend, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}