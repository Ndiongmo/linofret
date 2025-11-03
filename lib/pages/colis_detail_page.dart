import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../layouts/main_layout.dart';

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
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      setState(() {
        message = "Aucun token trouvé. Veuillez vous reconnecter.";
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
      AppConfig.api("/encodages/view/${widget.encodageId}.json"),
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
            final srcPath = images[0]["path"];
            //imagePath = "$imgHost/thinkfreight/images/store/$srcPath";
            imagePath = AppConfig.media(srcPath);
          }
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
      title: "Détail Coli",
      currentIndex: _currentIndex,
      onTabSelected: _navigateTo,
      child: isLoading
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
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                print(
                                  'Failed to load image from URL: $imagePath',
                                );
                                print('Flutter Error: $error');
                                return const Icon(
                                  Icons.broken_image,
                                  size: 100,
                                  color: Colors.grey,
                                );
                              },
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
