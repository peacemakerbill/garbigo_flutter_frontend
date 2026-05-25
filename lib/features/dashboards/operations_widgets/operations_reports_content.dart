import 'package:flutter/material.dart';

class OperationsReportsContent extends StatelessWidget {
  const OperationsReportsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reports & Analytics',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Performance insights and business reports',
            style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 32),

          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 900 ? 3 : 2;
              if (constraints.maxWidth < 600) crossAxisCount = 1;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: isMobile ? 12 : 16,
                mainAxisSpacing: isMobile ? 12 : 16,
                childAspectRatio: isMobile ? 2.2 : 1.85,
                children: const [
                  _ReportCard(
                    title: 'Collection Efficiency',
                    value: '94%',
                    trend: '+5%',
                    trendColor: Colors.green,
                  ),
                  _ReportCard(
                    title: 'Total Waste Collected',
                    value: '2.8T',
                    trend: 'This Month',
                    trendColor: Colors.green,
                  ),
                  _ReportCard(
                    title: 'Active Collectors',
                    value: '47',
                    trend: 'Online',
                    trendColor: Colors.green,
                  ),
                  _ReportCard(
                    title: 'Avg Response Time',
                    value: '18 min',
                    trend: '-3 min',
                    trendColor: Colors.green,
                  ),
                ],
              );
            },
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
  final Color trendColor;

  const _ReportCard({
    required this.title,
    required this.value,
    required this.trend,
    this.trendColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              trend,
              style: TextStyle(
                color: trendColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}