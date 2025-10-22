import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../layouts/main_layout.dart';
import 'pec_detail_page.dart';
import '../config/app_config.dart';
import 'pec_add_page.dart';

class PriseEnChargeListPage extends StatefulWidget {
  const PriseEnChargeListPage({super.key});

  @override
  State<PriseEnChargeListPage> createState() => _PriseEnChargeListPageState();
}

class _PriseEnChargeListPageState extends State<PriseEnChargeListPage> {
  List<dynamic> _pecList = [];
  bool _loading = true;
  String? _token;

  int _currentIndex = 1;

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
    _fetchPrisesEnCharge();
  }

  Future<void> _fetchPrisesEnCharge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString("jwt_token");

      if (_token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.post(
        Uri.parse(bon2commandesIndexUrl),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _pecList = data["Response"]["Bon2Commandes"] ?? [];
          _loading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return;
      } else {
        setState(() => _loading = false);
        debugPrint("Erreur API: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _loading = false);
      debugPrint("Erreur fetch: $e");
    }
  }

  void _openAdd() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => AddPrisePage()))
        .then((_) => _fetchPrisesEnCharge());
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "",
      currentIndex: _currentIndex,
      onTabSelected: _navigateTo,
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
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              ListView.builder(
                itemCount: _pecList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, i) {
                  final e = _pecList[i];
                  final id = e['id']?.toString() ?? '-';
                  final numPeC = e['numprisecharge']?.toString() ?? '-';
                  final status = e['status']?.toString() ?? '-';
                  final ordre = e['ordre2mission'];
                  final numExp = ordre != null
                      ? (ordre['id']?.toString() ?? '-')
                      : '-';
                  final created = e['created']?.toString() ?? '-';
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
                          Icons.inventory_2,
                          color: Colors.blue,
                        ),
                      ),
                      title: Text(
                        'N° PeC: $numPeC',
                      ), //ID : $id  — N° PeC: $numPeC
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: $status'),
                          Text('N° Exp: $numExp'),
                          Text('Date: $created'),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PriseEnChargeDetailsPage(
                              bon2commandeId: id.toString(),
                            ),
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
