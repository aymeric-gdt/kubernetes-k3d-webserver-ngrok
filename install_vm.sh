#!/bin/bash

source .env

## Installer Docker
#sudo apt-get update
#sudo apt-get install -y docker.io
#
## Installer kubectl
#sudo apt-get install -y kubectl

# Installer k3d
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

# Installer Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl create namespace dev

# Installer Ngrok
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
	| sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
	&& echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
	| sudo tee /etc/apt/sources.list.d/ngrok.list \
	&& sudo apt update \
	&& sudo apt install ngrok

# Installer jq
sudo apt-get install -y jq

# Créer un cluster Kubernetes avec k3d
k3d cluster create mycluster

# Configurer Argo CD avec un mot de passe spécifique
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "admin",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'

# Configurer ngrok (vous devrez vous inscrire sur ngrok.com pour obtenir un token)
ngrok config add-authtoken $NGROK_TOKEN
