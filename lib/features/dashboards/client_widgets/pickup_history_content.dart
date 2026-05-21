import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PickupHistoryContent extends StatelessWidget {
  const PickupHistoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - replace with real API later
    final mockHistory = [
      {
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'type': 'Mixed Waste',
        'status': 'Completed',
        'collector': 'John Mwangi',
        'amount': '12 kg',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'type': 'Plastic',
        'status': 'Completed',
        'collector': 'Sarah Wambui',
        'amount': '8 kg',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 12)),
        'type': 'Organic Waste',
        'status': 'In Progress',
        'collector': 'Peter Kamau',
        'amount': '15 kg',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pickup History',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Track all your waste collection requests',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mockHistory.length,
            itemBuilder: (context, index) {
              final item = mockHistory[index];
              final isCompleted = item['status'] == 'Completed';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: isCompleted ? Colors.green.shade100 : Colors.orange.shade100,
                    child: Icon(
                      isCompleted ? Icons.check_circle : Icons.pending,
                      color: isCompleted ? Colors.green : Colors.orange,
                    ),
                  ),
                  title: Text(
                    item['type'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Collector: ${item['collector']}'),
                      Text(DateFormat('dd MMM yyyy • hh:mm a').format(item['date'] as DateTime)),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item['amount'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        item['status'] as String,
                        style: TextStyle(
                          color: isCompleted ? Colors.green : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          if (mockHistory.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('No pickup history yet'),
              ),
            ),
        ],
      ),
    );
  }
}