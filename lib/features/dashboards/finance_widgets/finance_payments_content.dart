import 'package:flutter/material.dart';

class FinancePaymentsContent extends StatelessWidget {
  const FinancePaymentsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payments',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Track all incoming and outgoing payments',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.account_balance_wallet, size: 80, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Total Received This Month',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'KSh 1,847,500',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          const Text('Recent Transactions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.green),
                title: Text('Payment from Client ${index + 1}'),
                subtitle: const Text('M-Pesa • Today'),
                trailing: const Text('KSh 2,850', style: TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          ),
        ],
      ),
    );
  }
}