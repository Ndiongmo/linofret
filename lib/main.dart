// lib/main.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // pour kIsWeb

void main() {
  runApp(const MyApp());
}

// ====== CONFIG ======
// Si tu testes sur Android emulator, remplace 'http://localhost' par 'http://10.0.2.2'
const String baseHost =
    "http://localhost"; // <-- change to http://10.0.2.2 for Android emulator
const String loginUrl = "$baseHost/thinkfreight/api/v1/clients/token.json";
const String registerUrl = "$baseHost/thinkfreight/api/v1/clients/add.json";
const String viewProfileUrl = "$baseHost/thinkfreight/api/v1/clients/view.json";
const String destinatairesUrl =
    "$baseHost/thinkfreight/api/v1/clients/destinataire.json";
const String bon2commandesIndexUrl =
    "$baseHost/thinkfreight/api/v1/bon2commandes/index.json";
const String bon2commandesAddUrl =
    "$baseHost/thinkfreight/api/v1/bon2commandes/add.json";
const String encodagesIndexUrl =
    "$baseHost/thinkfreight/api/v1/encodages/index.json";
const String encodagesAddUrl =
    "$baseHost/thinkfreight/api/v1/encodages/add.json";
const String destinataireAddUrl =
    "$baseHost/thinkfreight/api/v1/clients/destinataire.json";
// ====================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThinkFreight Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const SplashOrLogin(),
    );
  }
}

// Splash checks token
class SplashOrLogin extends StatefulWidget {
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
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
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

// -------------------- LOGIN PAGE --------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String message = "";
  final ImagePicker _picker = ImagePicker();

  Future<void> doLogin() async {
    setState(() {
      isLoading = true;
      message = "";
    });

    try {
      final resp = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      final data = json.decode(resp.body);
      if (resp.statusCode == 200 &&
          data != null &&
          data['user'] != null &&
          data['user']['token'] != null) {
        final token = data['user']['token'];
        final clientData = data['user']['clientData'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('clientData', json.encode(clientData));

        setState(() {
          message = "✅ Connexion réussie";
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        setState(() {
          message = "❌ ${data["user"]["Message"] ?? 'Identifiants invalides'}";
        });
      }
    } catch (e) {
      setState(() {
        message = "⚠️ Erreur: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void goRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF66BB6A)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Image.asset('assets/logo.png', height: 110),
                  const SizedBox(height: 16),
                  const Text(
                    'Connexion ThinkFreight',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildField(emailController, 'Email', Icons.email),
                  const SizedBox(height: 12),
                  _buildField(
                    passwordController,
                    'Mot de passe',
                    Icons.lock,
                    obscure: true,
                  ),
                  const SizedBox(height: 20),
                  if (isLoading)
                    const CircularProgressIndicator(color: Colors.white)
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: doLogin,
                          icon: const Icon(Icons.login),
                          label: const Text('Se connecter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green.shade900,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: goRegister,
                          icon: const Icon(
                            Icons.person_add,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'S’inscrire',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(
                      color: message.startsWith('✅')
                          ? Colors.white
                          : Colors.red[200],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController c,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: c,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        fillColor: Colors.white.withOpacity(0.12),
        filled: true,
        prefixIcon: Icon(icon, color: Colors.white),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// -------------------- REGISTER PAGE --------------------
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final Map<String, TextEditingController> fields = {
    'nom': TextEditingController(),
    'prenom': TextEditingController(),
    'adresse1': TextEditingController(),
    'tel': TextEditingController(),
    'mobile': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
    'pays': TextEditingController(),
    'ville': TextEditingController(),
  };
  bool isLoading = false;
  String message = "";

  Future<void> doRegister() async {
    // basic validation
    for (var e in fields.entries) {
      if (e.value.text.trim().isEmpty) {
        setState(() {
          message = 'Champ ${e.key} obligatoire';
        });
        return;
      }
    }

    setState(() {
      isLoading = true;
      message = "";
    });

    try {
      final resp = await http.post(
        Uri.parse(registerUrl), // REGISTER_URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          for (var entry in fields.entries) entry.key: entry.value.text.trim(),
        }),
      );

      final data = json.decode(resp.body);
      if (resp.statusCode == 200 && data["Response"]["Status"] == "Success") {
        setState(() {
          message = '✅ Inscription réussie. Connectez-vous.';
        });
        // optionally go back to login
        Future.delayed(
          const Duration(seconds: 1),
          () => Navigator.of(context).pop(),
        );
      } else {
        setState(() {
          message =
              '❌ ${data["Response"]["errorMessage"] ?? 'Erreur inscription'}';
        });
      }
    } catch (e) {
      setState(() {
        message = '⚠️ Erreur: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildInput(
    String key,
    String label, {
    bool obscure = false,
    bool hidden = false,
  }) {
    final ctrl = fields[key]!;
    if (hidden) {
      // hidden with default values - used if needed
      ctrl.text = ctrl.text.isEmpty ? 'default' : ctrl.text;
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            for (var entry in fields.entries)
              _buildInput(
                entry.key,
                entry.key[0].toUpperCase() + entry.key.substring(1),
                obscure: entry.key == 'password',
              ),
            const SizedBox(height: 12),
            if (isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: doRegister,
                icon: const Icon(Icons.send),
                label: const Text("S’inscrire"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(
                color: message.startsWith('✅') ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
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
    final pages = [
      PrisesPage(token: token),
      ColisPage(token: token),
      DestinatairesPage(token: token),
    ];

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
}

// -------------------- PROFILE PAGE --------------------
class ProfilePage extends StatefulWidget {
  final String token;
  const ProfilePage({required this.token, super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? client;
  bool loading = true;
  String message = "";

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      loading = true;
      message = "";
    });
    try {
      final resp = await http.get(
        Uri.parse(viewProfileUrl), // VIEW_PROFILE_URL
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      final data = json.decode(resp.body);
      if (resp.statusCode == 200 && data["Response"]['Client'] != null) {
        client = data["Response"]['Client'];
      } else {
        message =
            data["Response"]['errorMessage'] ?? 'Erreur récupération profil';
      }
    } catch (e) {
      message = 'Erreur: $e';
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Widget _row(String label, String? value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value ?? '-')),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.green.shade700,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: client == null
                  ? Center(child: Text(message))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _row('Nom', client?['nom']),
                        _row('Prénom', client?['prenom']),
                        _row('Adresse 1', client?['adresse1']),
                        _row('Adresse 2', client?['adresse2']),
                        _row('Tel', client?['tel']),
                        _row('Mobile', client?['mobile']),
                        _row('Email', client?['email']),
                        _row('Ville', client?['ville']),
                        _row('Pays', client?['pays']),
                      ],
                    ),
            ),
    );
  }
}

// -------------------- PRISES PAGE --------------------
class PrisesPage extends StatefulWidget {
  final String token;
  const PrisesPage({required this.token, super.key});
  @override
  State<PrisesPage> createState() => _PrisesPageState();
}

class _PrisesPageState extends State<PrisesPage> {
  List<dynamic> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  Future<void> _loadList() async {
    setState(() {
      loading = true;
    });
    if (widget.token.isNotEmpty) {
      try {
        final resp = await http.post(
          Uri.parse(bon2commandesIndexUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${widget.token}',
          },
          body: json.encode({}),
        ); // some endpoints expect POST with body; leave empty or add pagination
        final data = json.decode(resp.body);
        // assuming response structure has Response -> Bon2Commandes as list
        if (data != null &&
            data['Response'] != null &&
            data['Response']['Bon2Commandes'] != null) {
          final raw = data['Response']['Bon2Commandes'];
          if (raw is List)
            items = raw;
          else if (raw is Map)
            items = [raw];
        } else {
          items = [];
        }
      } catch (e) {
        items = [];
      } finally {
        setState(() {
          loading = false;
        });
      }
    } else {
      // attendre un court instant puis réessayer si besoin
      Future.delayed(const Duration(milliseconds: 500), _loadList);
    }
  }

  void _openAdd() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => AddPrisePage(token: widget.token)),
        )
        .then((_) => _loadList());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadList,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _openAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter prise en charge'),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Liste PEC',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (loading)
              const Center(child: CircularProgressIndicator())
            else
              ListView.builder(
                itemCount: items.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, i) {
                  final e = items[i];
                  final id = e['id']?.toString() ?? '-';
                  final numPeC = e['numprisecharge']?.toString() ?? '-';
                  final status = e['status']?.toString() ?? '-';
                  final ordre = e['ordre2mission'];
                  final numExp = ordre != null
                      ? (ordre['id']?.toString() ?? '-')
                      : '-';
                  final created = e['created']?.toString() ?? '-';
                  return Card(
                    child: ListTile(
                      title: Text('ID : $id  — N° PeC: $numPeC'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: $status'),
                          Text('N° Exp: $numExp'),
                          Text('Date: $created'),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// -------------------- ADD PRISE PAGE --------------------
class AddPrisePage extends StatefulWidget {
  final String token;
  const AddPrisePage({required this.token, super.key});

  @override
  State<AddPrisePage> createState() => _AddPriseEnChargePageState();
}

class _AddPriseEnChargePageState extends State<AddPrisePage> {
  final formKey = GlobalKey<FormState>();

  // Contrôleurs
  final TextEditingController poidsController = TextEditingController();
  final TextEditingController descriptifController = TextEditingController();
  final TextEditingController doorEnlevementController =
      TextEditingController();
  final TextEditingController doorLivraisonController = TextEditingController();

  // Champs cachés
  String enlevementId = "3";
  String livraisonId = "4";

  // Dropdown destinataire
  List<Map<String, dynamic>> destinataires = [];
  String? selectedDestinataireId;

  bool isLoading = false;
  String message = "";

  @override
  void initState() {
    super.initState();
    _fetchDestinataires();
  }

  /// 🔹 Récupération de la liste des destinataires
  Future<void> _fetchDestinataires() async {
    try {
      /*final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");*/

      final url = Uri.parse(destinatairesUrl);
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["Response"]?["Destinataires"] != null) {
          final List<dynamic> list = data["Response"]["Destinataires"];

          setState(() {
            destinataires = list
                .map(
                  (item) => {
                    "id": item["destinataire"]["id"].toString(),
                    "name":
                        "${item["destinataire"]["nom"]} ${item["destinataire"]["prenom"]}",
                  },
                )
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Erreur chargement destinataires: $e");
    }
  }

  /// 🔹 Envoi du formulaire à l’API
  Future<void> _submitForm() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      message = "";
    });

    /*final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');*/

    final url = Uri.parse(bon2commandesAddUrl);

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: json.encode({
          "destinataireId": selectedDestinataireId,
          "poids": poidsController.text.trim(),
          "descriptif": descriptifController.text.trim(),
          "enlevementId": enlevementId,
          "doorEnlevement": doorEnlevementController.text.trim(),
          "livraisonId": livraisonId,
          "doorLivraison": doorLivraisonController.text.trim(),
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 &&
          data["Response"]["Status"] == 'Success') {
        setState(() {
          message = "✅ Prise en charge enregistrée avec succès !";
        });
        _clearForm();
        Future.delayed(
          const Duration(milliseconds: 800),
          () => Navigator.of(context).pop(),
        );
      } else {
        setState(() {
          message =
              "❌ ${data["Response"]["errorMessage"] ?? "Erreur lors de l’enregistrement"}";
        });
      }
    } catch (e) {
      setState(() {
        message = "⚠️ Erreur réseau : $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _clearForm() {
    poidsController.clear();
    //descriptifController.clear();
    doorEnlevementController.clear();
    doorLivraisonController.clear();
    selectedDestinataireId = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouvelle prise en charge"),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // 🔹 Liste déroulante destinataire
              DropdownButtonFormField<String>(
                value: selectedDestinataireId,
                decoration: const InputDecoration(
                  labelText: "Destinataire",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: destinataires.map((item) {
                  return DropdownMenuItem<String>(
                    value: item["id"],
                    child: Text(item["name"]),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDestinataireId = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Veuillez choisir un destinataire" : null,
              ),
              const SizedBox(height: 20),

              // 🔹 Poids
              TextFormField(
                controller: poidsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Poids (kg)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez renseigner le poids";
                  }
                  if (double.tryParse(value) == null) {
                    return "Poids invalide";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 🔹 Descriptif
              TextFormField(
                controller: descriptifController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Descriptif",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Descriptif requis" : null,
              ),
              const SizedBox(height: 20),

              // 🔹 Door Enlevement
              TextFormField(
                controller: doorEnlevementController,
                decoration: const InputDecoration(
                  labelText: "Adresse d’enlèvement (doorEnlevement)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Adresse d’enlèvement requise"
                    : null,
              ),
              const SizedBox(height: 20),

              // 🔹 Door Livraison
              TextFormField(
                controller: doorLivraisonController,
                decoration: const InputDecoration(
                  labelText: "Adresse de livraison (doorLivraison)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_shipping),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Adresse de livraison requise"
                    : null,
              ),
              const SizedBox(height: 30),

              // 🔹 Bouton enregistrer
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.save),
                      label: const Text(
                        "Enregistrer",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
              const SizedBox(height: 20),

              // 🔹 Message de retour
              Text(
                message,
                style: TextStyle(
                  color: message.startsWith("✅")
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- COLIS PAGE --------------------
class ColisPage extends StatefulWidget {
  final String token;
  const ColisPage({required this.token, super.key});
  @override
  State<ColisPage> createState() => _ColisPageState();
}

class _ColisPageState extends State<ColisPage> {
  List<dynamic> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
    });
    try {
      final resp = await http.post(
        Uri.parse(encodagesIndexUrl), //ENCODAGES_INDEX_URL
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: json.encode({}),
      );
      final data = json.decode(resp.body);
      if (data != null &&
          data['Response'] != null &&
          data['Response']['Encodages'] != null) {
        final raw = data['Response']['Encodages'];
        if (raw is List)
          items = raw;
        else if (raw is Map)
          items = [raw];
      } else
        items = [];
    } catch (e) {
      items = [];
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _addColis() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => AddColisPage(token: widget.token)),
        )
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _addColis,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter coli'),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Liste colis',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (loading)
              const CircularProgressIndicator()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final e = items[i];
                  final id = e['id']?.toString() ?? '-';
                  final designation = e['designation']?.toString() ?? '-';
                  final poids = e['poids']?.toString() ?? '-';
                  final desc = e['descriptif']?.toString() ?? '-';
                  return Card(
                    child: ListTile(
                      title: Text('$designation (ID:$id)'),
                      subtitle: Text('Poids: $poids\n$desc'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ColisDetailsPage(encodageId: id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// -------------------- VIEW DETAIL COLI PAGE -------------
class ColisDetailsPage extends StatefulWidget {
  final String encodageId;

  const ColisDetailsPage({super.key, required this.encodageId});

  @override
  State<ColisDetailsPage> createState() => _ColisDetailsPageState();
}

class _ColisDetailsPageState extends State<ColisDetailsPage> {
  bool isLoading = true;
  Map<String, dynamic>? encodageData;
  String? imagePath;
  String message = "";

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      setState(() {
        message = "Aucun token trouvé. Veuillez vous reconnecter.";
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
      "http://localhost/thinkfreight/api/v1/encodages/view/${widget.encodageId}.json",
    );

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final encodage = data["Response"]["Encodage"];

        setState(() {
          encodageData = encodage;
          final images = encodage["image2encodages"];
          if (images != null && images is List && images.isNotEmpty) {
            imagePath = images[0]["path"];
          }
          isLoading = false;
        });
      } else {
        setState(() {
          message = "Erreur serveur (${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        message = "Erreur réseau : $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails du colis"),
        backgroundColor: Colors.green.shade700,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : encodageData == null
          ? Center(
              child: Text(
                message.isNotEmpty ? message : "Aucune donnée trouvée.",
                style: const TextStyle(color: Colors.red),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imagePath != null)
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imagePath!,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.broken_image,
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      _infoRow("ID", encodageData?["id"]),
                      _infoRow("Désignation", encodageData?["designation"]),
                      _infoRow("Descriptif", encodageData?["descriptif"]),
                      _infoRow("Poids", encodageData?["poids"]),
                      _infoRow("Volume", encodageData?["volume"]),
                      _infoRow(
                        "Date Réception",
                        encodageData?["date_reception"],
                      ),
                      _infoRow(
                        "Date Livraison",
                        encodageData?["date_livraison"],
                      ),
                      _infoRow("Conteneur ID", encodageData?["conteneur_id"]),
                      _infoRow("Code Barre", encodageData?["codebarre"]),
                      _infoRow("QR Code", encodageData?["qrCode"]),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label : ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value != null && value.toString().isNotEmpty
                  ? value.toString()
                  : "—",
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- ADD COLIS PAGE --------------------
class AddColisPage extends StatefulWidget {
  final String token;
  const AddColisPage({required this.token, super.key});
  @override
  State<AddColisPage> createState() => _AddColisPageState();
}

class _AddColisPageState extends State<AddColisPage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedBon2CommandeId;
  String? selectedDesignation;
  final TextEditingController poidsController = TextEditingController();
  final TextEditingController descriptifController = TextEditingController();

  bool isLoading = false;
  String message = "";

  // Données API
  List<Map<String, dynamic>> bon2Commandes = [];

  // Fichiers uploadés
  List<PlatformFile> selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _fetchBon2Commandes();
  }

  /// 🔹 Récupération des prises en charge pour dropdown
  Future<void> _fetchBon2Commandes() async {
    try {
      /*final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");*/

      final url = Uri.parse(bon2commandesIndexUrl);
      final response = await http.post(
        url,
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["Response"]?["Bon2Commandes"] != null) {
          final List<dynamic> list = data["Response"]["Bon2Commandes"];
          setState(() {
            bon2Commandes = list
                .map(
                  (item) => {
                    "id": item["id"].toString(),
                    "numprisecharge": item["numprisecharge"] ?? "N/A",
                  },
                )
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Erreur chargement Bon2Commandes: $e");
    }
  }

  /// 🔹 Sélection des fichiers images
  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: true, // ⚠️ indispensable pour Flutter Web
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.files;
      });
    }
  }

  /// 🔹 Envoi du formulaire à l’API
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      message = "";
    });

    /*final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');*/

    final url = Uri.parse(encodagesAddUrl);
    final request = http.MultipartRequest("POST", url);
    request.headers["Authorization"] = "Bearer ${widget.token}";

    // Champs texte
    request.fields["bon2CommandeId"] = selectedBon2CommandeId ?? "";
    request.fields["designation"] = selectedDesignation ?? "";
    request.fields["poids"] = poidsController.text.trim();
    request.fields["descriptif"] = descriptifController.text.trim();

    // Upload fichiers
    // Gestion des fichiers upload
    for (var file in selectedFiles) {
      if (kIsWeb) {
        if (file.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              "images[]",
              file.bytes!,
              filename: file.name,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        } else {
          debugPrint("⚠️ File bytes is null for ${file.name}");
        }
      } else if (file.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "images[]",
            file.path!,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      } else {
        debugPrint("⚠️ File has no path or bytes: ${file.name}");
      }
    }

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = json.decode(respStr);

      if (response.statusCode == 200 &&
          data["Response"]["Status"] == "Success") {
        setState(() {
          message = "✅ Colis ajouté avec succès !";
        });
        _clearForm();
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pop(context, true); // 🔁 retour avec refresh
        });
      } else {
        setState(() {
          message =
              "❌ ${data["Response"]["errorMessage"] ?? "Erreur lors de l’ajout"}";
        });
      }
    } catch (e) {
      setState(() {
        message = "⚠️ Erreur réseau : $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _clearForm() {
    poidsController.clear();
    descriptifController.clear();
    selectedBon2CommandeId = null;
    selectedDesignation = null;
    selectedFiles.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un colis"),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔹 Dropdown Prise en charge
              DropdownButtonFormField<String>(
                value: selectedBon2CommandeId,
                decoration: const InputDecoration(
                  labelText: "Prise en charge (Bon2Commande)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.assignment),
                ),
                items: bon2Commandes.map((item) {
                  return DropdownMenuItem<String>(
                    value: item["id"],
                    child: Text("N° ${item["numprisecharge"]}"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBon2CommandeId = value;
                  });
                },
                validator: (value) => value == null
                    ? "Veuillez sélectionner une prise en charge"
                    : null,
              ),
              const SizedBox(height: 20),

              // 🔹 Dropdown Designation
              DropdownButtonFormField<String>(
                value: selectedDesignation,
                decoration: const InputDecoration(
                  labelText: "Désignation",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                items: const [
                  DropdownMenuItem(
                    value: '',
                    child: Text('Select Designation'),
                  ),
                  DropdownMenuItem(value: 'Voiture', child: Text('Voiture')),
                  DropdownMenuItem(
                    value: 'Électroménager',
                    child: Text('Électroménager'),
                  ),
                  DropdownMenuItem(value: 'Meuble', child: Text('Meuble')),
                  DropdownMenuItem(
                    value: 'Electronique',
                    child: Text('Electronique'),
                  ),
                  DropdownMenuItem(
                    value: 'Bureautique',
                    child: Text('Bureautique'),
                  ),
                  DropdownMenuItem(
                    value: 'Effet personnel',
                    child: Text('Effet personnel'),
                  ),
                  DropdownMenuItem(value: 'Autres', child: Text('Autres')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedDesignation = value;
                  });
                },
                validator: (value) => value == null || value.isEmpty
                    ? "Veuillez sélectionner une désignation"
                    : null,
              ),
              const SizedBox(height: 20),

              // 🔹 Poids
              TextFormField(
                controller: poidsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Poids (kg)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Poids requis";
                  if (double.tryParse(value) == null) return "Poids invalide";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 🔹 Descriptif
              TextFormField(
                controller: descriptifController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Descriptif",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Descriptif requis" : null,
              ),
              const SizedBox(height: 20),

              // 🔹 Upload fichiers
              ElevatedButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.upload_file),
                label: const Text("Ajouter des images"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade600,
                ),
              ),
              if (selectedFiles.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedFiles
                      .map((f) => Chip(label: Text(f.name)))
                      .toList(),
                ),
              ],
              const SizedBox(height: 30),

              // 🔹 Bouton enregistrer
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.save),
                      label: const Text("Enregistrer"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
              const SizedBox(height: 20),

              // 🔹 Message de retour
              Text(
                message,
                style: TextStyle(
                  color: message.startsWith("✅")
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- DESTINATAIRES PAGE --------------------
class DestinatairesPage extends StatefulWidget {
  final String token;
  const DestinatairesPage({required this.token, super.key});
  @override
  State<DestinatairesPage> createState() => _DestinatairesPageState();
}

class _DestinatairesPageState extends State<DestinatairesPage> {
  List<dynamic> list = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
    });
    try {
      final resp = await http.get(
        Uri.parse(destinatairesUrl),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );
      final data = json.decode(resp.body);
      if (data != null &&
          data['Response'] != null &&
          data['Response']['Destinataires'] != null) {
        final d = data['Response']['Destinataires'];
        if (d is List)
          list = d;
        else if (d is Map)
          list = [d];
      } else
        list = [];
    } catch (e) {
      list = [];
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _addDest() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => AddDestinatairePage(token: widget.token),
          ),
        )
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _addDest,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter destinataire'),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Liste dest.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (loading)
              const CircularProgressIndicator()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final d = list[i];
                  final id = d['destinataire']['id']?.toString() ?? '-';
                  final nom = d['destinataire']['nom'] ?? '';
                  final prenom = d['destinataire']['prenom'] ?? '';
                  final name = ('$nom $prenom').trim();
                  final addr = d['destinataire']['adresse1'] ?? '-';
                  return Card(
                    child: ListTile(
                      title: Text('$name (ID:$id)'),
                      subtitle: Text('Adresse: $addr'),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// -------------------- ADD DESTINATAIRE PAGE --------------------
class AddDestinatairePage extends StatefulWidget {
  final String token;
  const AddDestinatairePage({required this.token, super.key});
  @override
  State<AddDestinatairePage> createState() => _AddDestinatairePageState();
}

class _AddDestinatairePageState extends State<AddDestinatairePage> {
  final Map<String, TextEditingController> fields = {
    'nom': TextEditingController(),
    'prenom': TextEditingController(),
    'adresse1': TextEditingController(),
    'tel': TextEditingController(),
    'mobile': TextEditingController(),
    'email': TextEditingController(
      text: 'default@linofret.com',
    ), // default value (hidden requirement)
    'password': TextEditingController(
      text: 'defaultpass@123',
    ), // default value (hidden)
    'pays': TextEditingController(),
    'ville': TextEditingController(),
  };
  String message = '';
  bool loading = false;

  Future<void> submit() async {
    // required fields check
    if (fields['nom']!.text.trim().isEmpty ||
        fields['prenom']!.text.trim().isEmpty) {
      setState(() {
        message = 'Nom & Prenom requis';
      });
      return;
    }
    setState(() {
      loading = true;
      message = '';
    });
    try {
      final resp = await http.post(
        Uri.parse(destinataireAddUrl),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          for (var e in fields.entries) e.key: e.value.text.trim(),
        }),
      );
      final data = json.decode(resp.body);
      if (resp.statusCode == 200 && data["Response"]["Status"] == "Success") {
        setState(() {
          message = '✅ Destinataire ajouté';
        });
        Future.delayed(
          const Duration(milliseconds: 800),
          () => Navigator.of(context).pop(),
        );
      } else {
        setState(() {
          message = '❌ ${data["Response"]["errorMessage"] ?? 'Erreur'}';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Erreur: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Widget _field(String key, String label, {bool hidden = false}) {
    if (hidden) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: fields[key],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter destinataire'),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _field('nom', 'Nom'),
            _field('prenom', 'Prénom'),
            _field('adresse1', 'Adresse1'),
            _field('tel', 'Tel'),
            _field('mobile', 'Mobile'),
            // email & password are hidden as requested (but kept default value)
            const SizedBox(height: 6),
            _field('pays', 'Pays'),
            _field('ville', 'Ville'),
            const SizedBox(height: 10),
            if (loading)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: submit,
                icon: const Icon(Icons.save),
                label: const Text(
                  "Enregistrer",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            if (message.isNotEmpty)
              Text(
                message,
                style: TextStyle(
                  color: message.startsWith('✅') ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
