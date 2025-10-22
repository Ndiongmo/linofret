import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/pec');
        break;
      case 2:
        Navigator.pushNamed(context, '/colis');
        break;
      case 3:
        Navigator.pushNamed(context, '/destinataires');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "Home",
      currentIndex: _currentIndex,
      onTabSelected: _navigateTo,

      // ✅ Drawer visible uniquement sur mobile
      /*endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green.shade700),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.green, size: 36),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Bienvenue !",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("Profil"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Déconnexion"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),*/
      child: const Center(
        child: Text(
          'Bienvenue sur ThinkFreight !',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),

      /*bottomNavigationBar: FooterMenu(
        currentIndex: _currentIndex,
        onTabSelected: _navigateTo,
      ),*/
    );
  }
}
