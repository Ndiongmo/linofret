import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/pages/colis_detail_page.dart';
import '../layouts/main_layout.dart';

// -------------------- Colis Lié à la prise en charge PAGE --------
class ColisLiePage extends StatefulWidget {
  final String bon2commandeId;
  const ColisLiePage({super.key, required this.bon2commandeId});

  @override
  State<ColisLiePage> createState() => _ColisLiePageState();
}

class _ColisLiePageState extends State<ColisLiePage> {
  bool isLoading = true;
  List<dynamic> colisList = [];
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
    _fetchColis();
  }

  Future<void> _fetchColis() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null || token.isEmpty) {
      setState(() {
        message = "Aucun token trouvé.";
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse(encodagesIndexUrl);

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"bon2commande_id": widget.bon2commandeId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final colis = data["Response"]["Encodages"] ?? [];
        setState(() {
          colisList = colis;
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return;
      } else {
        setState(() {
          message = "Erreur serveur : ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        message = "Erreur : $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "Colis Liés",
      currentIndex: _currentIndex,
      onTabSelected: _navigateTo,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : colisList.isEmpty
          ? Center(
              child: Text(
                message.isNotEmpty
                    ? message
                    : "Aucun colis lié à cette prise en charge.",
                style: const TextStyle(color: Colors.black54),
              ),
            )
          : ListView.builder(
              itemCount: colisList.length,
              itemBuilder: (context, index) {
                final colis = colisList[index];
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
                    title: Text(
                      "${colis["designation"] ?? "Colis"} - ${colis["poids"] ?? "?"} kg",
                    ),
                    subtitle: Text(colis["descriptif"] ?? ""),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // 👇 Navigation locale vers la page de détail colis
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ColisDetailsPage(
                            encodageId: colis["id"].toString(),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
