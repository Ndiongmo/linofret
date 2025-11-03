import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/config/app_config.dart';
import '/pages/colis_add_page.dart';
import '/pages/colis_detail_page.dart';
import '../layouts/main_layout.dart';

// -------------------- COLIS PAGE --------------------
class ColisPage extends StatefulWidget {
  const ColisPage({super.key});
  @override
  State<ColisPage> createState() => _ColisPageState();
}

class _ColisPageState extends State<ColisPage> {
  List<dynamic> items = [];
  bool loading = true;
  String? _token;

  int _currentIndex = 2;

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
    setState(() {
      loading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString("jwt_token");

      if (_token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final resp = await http.post(
        Uri.parse(AppConfig.api("/encodages/index.json")), //encodagesIndexUrl
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
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
      } else if (resp.statusCode == 401) {
        setState(() {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return;
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
        .push(MaterialPageRoute(builder: (_) => AddColisPage()))
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "",
      currentIndex: _currentIndex,
      onTabSelected: _navigateTo,
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
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(
                          Icons.local_shipping,
                          color: Colors.blue,
                        ),
                      ),
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
