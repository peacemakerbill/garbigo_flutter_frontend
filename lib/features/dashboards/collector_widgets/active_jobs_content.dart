import 'package:flutter/material.dart';

class ActiveJobsContent extends StatelessWidget {
  const ActiveJobsContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - replace with real API + Riverpod later
    final activeJobs = [
      {
        'client': 'Alice Wanjiku',
        'address': 'Westlands, Nairobi',
        'time': 'Today • 2:30 PM',
        'waste': 'Mixed Waste • 18kg',
        'status': 'Accepted'
      },
      {
        'client': 'James Omondi',
        'address': 'Kilimani, Nairobi',
        'time': 'Today • 4:00 PM',
        'waste': 'Plastic • 12kg',
        'status': 'En Route'
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Active Jobs', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Currently assigned collections', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeJobs.length,
            itemBuilder: (context, index) {
              final job = activeJobs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(radius: 24, backgroundColor: Colors.green),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(job['client']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                Text(job['address']!, style: TextStyle(color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(job['status']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pickup Time', style: TextStyle(fontSize: 13)),
                              Text(job['time']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Waste', style: TextStyle(fontSize: 13)),
                              Text(job['waste']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Start Navigation', style: TextStyle(fontWeight: FontWeight.bold)),
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