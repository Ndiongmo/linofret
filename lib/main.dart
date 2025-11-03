import 'package:flutter/material.dart';
import '/pages/login_page.dart';
import '/pages/profile_page.dart';
import 'pages/pec_list_page.dart';
import 'pages/colis_list_page.dart';
import 'pages/register_page.dart';
import 'pages/destinataire_list_page.dart';
import 'pages/home_page.dart';
import 'pages/logout_page.dart';
import 'config/app_config.dart';

void main() {
  AppConfig.init(); // Auto ou via .env.dart
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 🌿 Thème Linofret global
  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.blue,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      scaffoldBackgroundColor: Colors.grey.shade100,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.blue.shade800,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Linofret App',
      theme: _buildTheme(),
      // 🌍 Déclaration de toutes les routes ici
      // routes:
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/pec': (context) => const PriseEnChargeListPage(),
        '/colis': (context) => ColisPage(),
        '/destinataires': (context) => DestinatairesPage(),
        '/profile': (context) => ProfilePage(),
        '/logout': (context) => const LogoutPage(),
      },
      // 🔑 Première page affichée au lancement
      initialRoute: '/login',
    );
  }
}

// Splash checks token
/*class SplashOrLogin extends StatefulWidget {
  const SplashOrLogin({super.key});

  @override
  State<SplashOrLogin> createState() => _SplashOrLoginState();
}

class _SplashOrLoginState extends State<SplashOrLogin> {
  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      // go to main app
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      ); // to be replaced with MainScreen
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), checkAuth);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

// -------------------- MAIN SCREEN (with bottom nav) --------------------
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // 0: prises,1:colis,2:destinataires
  Map<String, dynamic>? clientData;
  String token = '';

  @override
  void initState() {
    super.initState();
    _loadAuth();
  }

  Future<void> _loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    final clientJson = prefs.getString('clientData');
    if (clientJson != null) clientData = json.decode(clientJson);

    if (token.isNotEmpty) {
      //await fetchPrisesEnCharge(token);
    } else {
      // attendre un court instant puis réessayer si besoin
      Future.delayed(const Duration(milliseconds: 500), _loadAuth);
    }

    setState(() {});
  }

  void _onLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('clientData');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _openProfile() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ProfilePage(token: token)));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [PriseEnChargeListPage(), ColisPage(), DestinatairesPage()];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 36),
            const SizedBox(width: 8),
            const Text('Linofret'),
            const Spacer(),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (val) {
                if (val == 'profile') _openProfile();
                if (val == 'logout') _onLogout();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'profile', child: Text('Profil')),
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Se déconnecter'),
                ),
              ],
            ),
          ],
        ),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Prises en charges',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Colis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Destinataires',
          ),
        ],
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}*/
