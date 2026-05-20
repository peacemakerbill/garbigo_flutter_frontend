import 'package:flutter/material.dart';

class ClientSidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const ClientSidebar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.recycling,
                  color: Colors.green,
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  'Garbigo',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          _SidebarButton(
            icon: Icons.home,
            title: 'Home',
            index: 0,
            currentIndex: currentIndex,
            onTap: onIndexChanged,
          ),
          _SidebarButton(
            icon: Icons.schedule,
            title: 'Schedule Pickup',
            index: 1,
            currentIndex: currentIndex,
            onTap: onIndexChanged,
          ),
          _SidebarButton(
            icon: Icons.history,
            title: 'History',
            index: 2,
            currentIndex: currentIndex,
            onTap: onIndexChanged,
          ),
          _SidebarButton(
            icon: Icons.person,
            title: 'Profile',
            index: 3,
            currentIndex: currentIndex,
            onTap: onIndexChanged,
          ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SidebarButton({
    required this.icon,
    required this.title,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Colors.green.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}