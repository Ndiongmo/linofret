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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Bienvenue sur Linofret!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gérez votre logistique de fret avec efficacité.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 30),

            // --- Card 1: Suivi en temps réel ---
            _buildFeatureCard(
              context,
              icon: Icons.track_changes,
              title: 'Suivi de Marchandises en Temps Réel',
              description:
                  'Gardez un œil sur vos expéditions du départ à l\'arrivée. Recevez des mises à jour instantanées sur le statut de vos colis et anticipez les livraisons. Nos systèmes de suivi avancés vous offre une visibilité complète sur la chaîne d\'approvisionnement.',
              color: Colors.blue.shade50, // Soft blue background
            ),
            const SizedBox(height: 20),

            // --- Card 2: Gestion des Clients et Destinations ---
            _buildFeatureCard(
              context,
              icon: Icons.people_alt,
              title: 'Gestion Centralisée des Clients et Destinations',
              description:
                  'Accédez facilement à toutes les informations de vos clients et à leurs adresses de destination. Optimisez vos itinéraires et personnalisez vos services grâce à un accès rapide à des données organisées et à jour.',
              color: Colors.green.shade50, // Soft green background
            ),
            const SizedBox(height: 20),

            // --- Card 3: Optimisation des Itinéraires ---
            _buildFeatureCard(
              context,
              icon: Icons.route,
              title: 'Optimisation Intelligente des Itinéraires',
              description:
                  'Minimisez les coûts et les délais de livraison grâce à nos algorithmes d\'optimisation d\'itinéraires. Nous prennons en compte les conditions de trafic et les contraintes de temps pour des livraisons plus rapides et plus économiques.',
              color: Colors.orange.shade50, // Soft orange background
            ),
            const SizedBox(height: 20),

            // --- Optional: Call to action or footer ---
            Center(
              child: Text(
                'Simplifiez votre logistique dès aujourd\'hui !',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),

      /*bottomNavigationBar: FooterMenu(
        currentIndex: _currentIndex,
        onTabSelected: _navigateTo,
      ),*/
    );
  }

  //Helper method to build a consistent feature card
  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    Color? color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: color, // Use the provided color
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).primaryColor, // Use app's primary color
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5, // Improve readability
                color: Colors.black54,
              ),
              textAlign:
                  TextAlign.justify, // Justify text for better appearance
            ),
          ],
        ),
      ),
    );
  }
}
