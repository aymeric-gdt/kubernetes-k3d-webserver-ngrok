#!/bin/bash

source .env

# Démarrer ngrok
ngrok http 8080 &

# Attendre que ngrok soit prêt
sleep 5

# Obtenir l'URL ngrok
NGROK_URL=$(curl -s localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')

# Configurer le webhook GitHub (vous aurez besoin d'un token GitHub)
curl -X POST -H "Authorization: token $TOKEN_GITHUB" \
     -H "Content-Type: application/json" \
     -d '{"name": "web", "active": true, "events": ["push"], "config": {"url": "'$NGROK_URL'", "content_type": "json"}}' \
     https://api.github.com/repos/votreusername/votre-repo/hooks
