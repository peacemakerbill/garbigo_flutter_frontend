import 'package:flutter/material.dart';

class OperationsCollectionsContent extends StatelessWidget {
  const OperationsCollectionsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Live Collections', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Monitor ongoing waste collections in real-time', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 24),

          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.local_shipping, size: 80, color: Colors.green),
                    SizedBox(height: 16),
                    Text('Live Tracking Map', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('(Integration ready)', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}