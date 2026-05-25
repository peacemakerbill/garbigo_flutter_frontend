import 'package:flutter/material.dart';

class SupportKnowledgeContent extends StatelessWidget {
  const SupportKnowledgeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Knowledge Base',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Help articles and FAQs for customers & staff',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          const Text('Popular Articles', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return const Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(Icons.article, color: Colors.green),
                  title: Text('How to schedule a pickup for bulk waste?'),
                  subtitle: Text('Updated 2 days ago'),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}