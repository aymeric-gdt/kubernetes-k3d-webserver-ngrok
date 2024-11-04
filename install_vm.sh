#!/bin/bash

source .env

# Fonction pour ajouter une pause et afficher un message
pause() {
    echo "Étape terminée : $1"
    sleep $2
    echo "Passage à l'étape suivante..."
}

# Installer Docker
sudo apt-get update
sudo apt-get install -y docker.io
pause "Installation de Docker" 5

# Installer kubectl
sudo apt-get install -y kubectl
pause "Installation de kubectl" 5

# Installer k3d
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
pause "Installation de k3d" 5

# Créer un cluster Kubernetes avec k3d
k3d cluster create mycluster
pause "Création du cluster Kubernetes" 5

# Installer Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
pause "Installation d'Argo CD" 5

# Configurer Argo CD avec un mot de passe spécifique
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "votreMotDePasse",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'
pause "Configuration du mot de passe Argo CD" 3

# Installer ngrok
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
	| sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
	&& echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
	| sudo tee /etc/apt/sources.list.d/ngrok.list \
	&& sudo apt update \
	&& sudo apt install ngrok
pause "Installation de ngrok" 20

# Installer jq
sudo apt-get install -y jq
pause "Installation de jq" 5

# Configurer ngrok (vous devrez vous inscrire sur ngrok.com pour obtenir un token)
ngrok authtoken $NGROK_TOKEN
pause "Configuration de ngrok" 2

echo "Installation terminée !"
