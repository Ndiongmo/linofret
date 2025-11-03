/// Fichier d’environnement local facultatif.
/// Copie ce fichier sous le nom `env.dart` et adapte les valeurs.
///
/// ⚠️ Ce fichier ne doit PAS être poussé sur Git (ajoute-le dans ton .gitignore)

class Env {
  static const String apiBaseUrl = "https://thinkfreight.be/api/v1";
  static const String mediaBaseUrl =
      "https://thinkfreight.be/api/v1/encodages/image/";
  static const String environment = "prod"; // "local" ou "demo"
}
