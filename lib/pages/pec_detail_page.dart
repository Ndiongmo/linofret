import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colis_lie_page.dart';
import '../layouts/main_layout.dart';

// -------------------- PRISE EN CHARGE DETAILS PAGE --------------------
class PriseEnChargeDetailsPage extends StatefulWidget {
  final String bon2commandeId;

  const PriseEnChargeDetailsPage({super.key, required this.bon2commandeId});

  @override
  State<PriseEnChargeDetailsPage> createState() =>
      _PriseEnChargeDetailsPageState();
}

class _PriseEnChargeDetailsPageState extends State<PriseEnChargeDetailsPage> {
  bool isLoading = true;
  Map<String, dynamic>? bonData;
  String message = "";

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
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      setState(() {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return;
    }

    final url = Uri.parse(
      AppConfig.api("/bon2commandes/view/${widget.bon2commandeId}.json"),
    ); //bon2commandesViewUrl

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bon = data["Response"]["Bon2Commande"];
        setState(() {
          bonData = bon;
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return;
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
    return MainLayout(
      title: "Détail PeC",
      currentIndex: _currentIndex,
      onTabSelected: _navigateTo,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bonData == null
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
                      _infoRow("ID", bonData?["id"]),
                      _infoRow("N° PeC", bonData?["numprisecharge"]),
                      _infoRow("Expéditeur", bonData?["expediteur"] ?? ""),
                      _infoRow(
                        "Destinataire",
                        "${bonData?["ordre2mission"]?["destinataire"]?["nom"] ?? ""} ${bonData?["ordre2mission"]?["destinataire"]?["prenom"] ?? ""}",
                      ),
                      _infoRow(
                        "Lieu Enlèvement",
                        bonData?["ordre2mission"]?["door_enlevement"] ?? "",
                      ),
                      _infoRow(
                        "Lieu Livraison",
                        bonData?["ordre2mission"]?["door_livraison"] ?? "",
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.local_shipping_outlined),
                        label: const Text("Voir les colis liés"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ColisLiePage(
                                bon2commandeId: bonData?["id"].toString() ?? "",
                              ),
                            ),
                          );
                        },
                      ),
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
