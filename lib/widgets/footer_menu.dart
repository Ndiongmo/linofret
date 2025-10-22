import 'package:flutter/material.dart';

class FooterMenu extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const FooterMenu({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: Colors.white,
      indicatorColor: Colors.blue.shade100,
      elevation: 8,
      height: 65,
      selectedIndex: currentIndex,
      onDestinationSelected: onTabSelected,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_outlined, color: Colors.blue),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2, color: Colors.blue),
          label: 'PeC',
        ),
        NavigationDestination(
          icon: Icon(Icons.local_shipping_outlined),
          selectedIcon: Icon(Icons.local_shipping, color: Colors.blue),
          label: 'Colis',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people, color: Colors.blue),
          label: 'Destinataires',
        ),
      ],
    );
  }
}
