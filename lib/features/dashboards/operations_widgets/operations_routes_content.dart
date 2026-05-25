import 'package:flutter/material.dart';

class OperationsRoutesContent extends StatelessWidget {
  const OperationsRoutesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Route Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Optimize and monitor collection routes', style: TextStyle(fontSize: 16, color: Color(0xFF757575))),
          SizedBox(height: 32),

          Center(
            child: Icon(Icons.map, size: 120, color: Colors.green),
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Interactive Map & Route Optimization\n(Coming Soon)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 40),

          // Mock Active Routes
          Text('Active Routes Today', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          SizedBox(height: 16),
          // Add real route cards here later
        ],
      ),
    );
  }
}