import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CollectorPickupHistoryContent extends StatelessWidget {
  const CollectorPickupHistoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - replace with real data from API later
    final history = [
      {
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'client': 'Mercy Chege',
        'type': 'Mixed Waste',
        'amount': '22 kg',
        'earnings': 'KSh 850',
        'status': 'Completed'
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'client': 'Brian Kipchoge',
        'type': 'Plastic',
        'amount': '14 kg',
        'earnings': 'KSh 620',
        'status': 'Completed'
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
            'All completed collections',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(18),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                  title: Text(
                    item['client'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item['type'] as String} • ${item['amount'] as String}'),
                      Text(
                        DateFormat('dd MMM yyyy • hh:mm a')
                            .format(item['date'] as DateTime),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item['earnings'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        item['status'] as String,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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