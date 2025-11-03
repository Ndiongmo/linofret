import 'package:flutter/foundation.dart';
import 'env.dart' as env;

/// Configuration centralisée pour les environnements ThinkFreight
class AppConfig {
  static late final String apiBaseUrl;
  static late final String mediaBaseUrl;
  static late final String environment;

  /// Initialisation automatique à l'import
  static void init({String? forceEnv}) {
    // ⚙️ Étape 1 — Vérifie si on a un .env.dart (manuel)
    try {
      environment = forceEnv ?? env.Env.environment;
      apiBaseUrl = env.Env.apiBaseUrl;
      mediaBaseUrl = env.Env.mediaBaseUrl;
      debugPrint("✅ AppConfig chargé depuis env.dart ($environment)");
      return;
    } catch (e) {
      // S’il n’existe pas, on passe à la détection automatique
      debugPrint("⚙️ Aucun env.dart trouvé, détection automatique en cours...");
    }

    // ⚙️ Étape 2 — Détection automatique
    if (forceEnv != null) {
      environment = forceEnv;
    } else if (kDebugMode) {
      environment = "local";
    } else if (kProfileMode) {
      environment = "demo";
    } else if (kReleaseMode) {
      environment = "prod";
    } else {
      environment = "local";
    }

    // ⚙️ Étape 3 — Définition des URLs selon l’environnement
    switch (environment) {
      case "local":
        apiBaseUrl = "http://localhost/thinkfreight/api/v1";
        //mediaBaseUrl = "http://localhost/thinkfreight/images/store";
        mediaBaseUrl = "http://localhost/thinkfreight/api/v1/encodages/image/";
        break;
      case "demo":
        apiBaseUrl = "https://thinkfreight.be/api/v1";
        mediaBaseUrl = "https://thinkfreight.be/api/v1/encodages/image/";
        break;
      case "prod":
      default:
        apiBaseUrl = "https://thinkfreight.be/api/v1";
        mediaBaseUrl = "https://thinkfreight.be/api/v1/encodages/image/";
        break;
    }

    debugPrint("✅ AppConfig initialisé automatiquement ($environment)");
  }

  static String api(String endpoint) => "$apiBaseUrl$endpoint";
  static String media(String path) {
    String finalpath = path.trim();
    if (path.startsWith("http")) {
      finalpath = path;
    } else {
      finalpath = "$mediaBaseUrl/$path";
    }

    // 1. Replace backslashes with forward slashes
    finalpath = finalpath.replaceAll("\\", "/");

    // 2. Normalize multiple slashes to single slashes,
    //    but keep the http:// prefix intact.
    finalpath = finalpath.replaceAllMapped(
      RegExp(
        r'(?<!:)/{2,}',
      ), // Regex to find two or more slashes NOT preceded by a colon
      (match) => '/', // Replace with a single slash
    );
    return finalpath;
  }
}
