#!/bin/bash
# =========================================
# 🚀 Script de déploiement Flutter Web - OVH (Démo)
# Auteur : Maurice Lionel Ndiongmo
# =========================================

# --- CONFIGURATION ---
REMOTE_USER="linofrc-app"
REMOTE_HOST="ssh.cluster130.hosting.ovh.net"
REMOTE_PATH="www/linofret_demo"
ENV_FILE="lib/config/env.demo.dart"
ENV_TARGET="lib/config/env.dart"

echo "-------------------------------------"
echo "🚀 Déploiement Flutter Web (env: DEMO)"
echo "-------------------------------------"

# 1️⃣ Vérification du dossier Flutter
if [ ! -d ".git" ]; then
  echo "❌ Ce script doit être exécuté à la racine du projet Flutter."
  exit 1
fi

# 2️⃣ Préparation de l'environnement
if [ -f "$ENV_FILE" ]; then
  echo "📦 Copie du fichier d'environnement demo..."
  cp "$ENV_FILE" "$ENV_TARGET"
else
  echo "❌ Fichier $ENV_FILE introuvable."
  exit 1
fi

# 3️⃣ Build Flutter Web
echo "⚙️  Construction du projet Flutter Web..."
flutter build web --release

if [ $? -ne 0 ]; then
  echo "❌ Erreur pendant le build Flutter."
  exit 1
fi

# 4️⃣ Vérification du dossier build/web
if [ ! -d "build/web" ]; then
  echo "❌ Le dossier build/web est introuvable."
  exit 1
fi

# 5️⃣ Transfert vers OVH
echo "📡 Transfert des fichiers vers OVH..."
scp -r build/web/* ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/

if [ $? -eq 0 ]; then
  echo "✅ Déploiement terminé avec succès !"
  echo "🌍 URL : https://${REMOTE_HOST}/${REMOTE_PATH}/"
else
  echo "❌ Échec du transfert vers OVH."
  exit 1
fi


