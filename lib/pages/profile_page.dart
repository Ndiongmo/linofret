// -------------------- PROFILE PAGE --------------------
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/config/app_config.dart';
import '../layouts/main_layout.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? client;
  bool loading = true;
  String message = "";
  String? _token;

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
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString("jwt_token");

      if (_token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      final resp = await http.get(
        Uri.parse(AppConfig.api("/clients/view.json")), // viewProfileUrl
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      final data = json.decode(resp.body);
      if (resp.statusCode == 200 && data["Response"]['Client'] != null) {
        client = data["Response"]['Client'];
      } else if (resp.statusCode == 401) {
        setState(() {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return;
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
    return MainLayout(
      title: "Profil",
      currentIndex: _currentIndex,
      onTabSelected: _navigateTo,
      child: loading
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
