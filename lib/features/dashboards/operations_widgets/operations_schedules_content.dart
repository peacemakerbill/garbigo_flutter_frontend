import 'package:flutter/material.dart';

class OperationsSchedulesContent extends StatelessWidget {
  const OperationsSchedulesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pickup Schedules', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Manage all upcoming collection requests', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 24),

          // TODO: Replace with real data from API
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.calendar_today, color: Colors.white),
                  ),
                  title: Text('Client ${index + 1} - Mixed Waste'),
                  subtitle: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tomorrow • 10:30 AM'),
                      Text('Location: Westlands, Nairobi'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Assign'),
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