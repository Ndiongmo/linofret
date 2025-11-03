import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/config/app_config.dart';
import '/pages/destinataire_add_page.dart';
import '../layouts/main_layout.dart';

// -------------------- DESTINATAIRES PAGE --------------------
class DestinatairesPage extends StatefulWidget {
  const DestinatairesPage({super.key});
  @override
  State<DestinatairesPage> createState() => _DestinatairesPageState();
}

class _DestinatairesPageState extends State<DestinatairesPage> {
  List<dynamic> list = [];
  bool loading = true;
  String? _token;

  int _currentIndex = 3;

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
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("jwt_token");

    if (_token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() {
      loading = true;
    });
    try {
      final resp = await http.get(
        Uri.parse(
          AppConfig.api("/clients/destinataire.json"),
        ), //destinatairesUrl
        headers: {
          'Authorization': 'Bearer $_token',
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
      } else if (resp.statusCode == 401) {
        setState(() {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return;
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
        .push(MaterialPageRoute(builder: (_) => AddDestinatairePage()))
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "",
      currentIndex: _currentIndex,
      onTabSelected: _navigateTo,
      //onRefresh: _load,
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
                  'Liste destinataires',
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
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(Icons.people, color: Colors.blue),
                      ),
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
