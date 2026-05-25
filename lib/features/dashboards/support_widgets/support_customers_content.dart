import 'package:flutter/material.dart';

class SupportCustomersContent extends StatelessWidget {
  const SupportCustomersContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customers',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'View and manage customer information',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

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
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text('Customer ${index + 1}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('client${index + 1}@example.com'),
                      const Text('Nairobi, Kenya'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    child: const Text('View Profile'),
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