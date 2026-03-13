import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/route_names.dart';

class ShellNavigationScreen extends StatelessWidget {
  const ShellNavigationScreen({
    super.key,
    required this.navigationShell,
    required this.onLogout,
  });

  final StatefulNavigationShell navigationShell;
  final VoidCallback onLogout;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _goBranch,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
