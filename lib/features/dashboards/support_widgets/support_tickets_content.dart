import 'package:flutter/material.dart';

class SupportTicketsContent extends StatelessWidget {
  const SupportTicketsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Support Tickets',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage and resolve customer support requests',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            itemBuilder: (context, index) {
              final priority = index % 3 == 0 ? 'High' : 'Medium';
              final color = priority == 'High' ? Colors.red : Colors.orange;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.1),
                    child: Icon(Icons.support_agent, color: color),
                  ),
                  title: Text('Ticket #SUP-${100 + index} • Payment Issue'),
                  subtitle: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Client: Jane Muthoni'),
                      Text('Created: 2 hours ago'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Chip(
                        label: Text(priority, style: const TextStyle(fontSize: 12)),
                        backgroundColor: color.withOpacity(0.1),
                        labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text('Open', style: TextStyle(color: Colors.green)),
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