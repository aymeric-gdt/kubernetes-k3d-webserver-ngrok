#!/bin/bash

# Fonction pour ajouter une pause et afficher un message
pause() {
    echo "Étape terminée : $1"
    sleep 5
    echo "Passage à l'étape suivante..."
}

# Installation de Docker
sudo apt-get update
sudo apt-get install -y docker.io
pause "Installation de Docker"

# Installation de kubectl
sudo apt-get install -y kubectl
pause "Installation de kubectl"

# Installation de k3d
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
pause "Installation de k3d"

# Création du cluster Kubernetes
k3d cluster create mycluster
pause "Création du cluster Kubernetes"

# Création des namespaces
kubectl create namespace argocd
kubectl create namespace dev
pause "Création des namespaces"

# Installation d'Argo CD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
pause "Installation d'Argo CD"

# Application des fichiers YAML
cat <<EOF > app-argo-cd.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/aymeric-gdt/kubernetes-k3d-webserver-ngrok
    targetRevision: HEAD
    path: .
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      selfHeal: true
      prune: false
EOF

cat <<EOF > ingress-app.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  namespace: dev
spec:
  rules:
  - http:
      paths:
      - path: /app
        pathType: Prefix
        backend:
          service:
            name: myapp-service
            port: 
              number: 8080
EOF

cat <<EOF > ingress-argocd.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port: 
              number: 80
EOF

kubectl apply -f app-argo-cd.yaml
kubectl apply -f ingress-app.yaml
kubectl apply -f ingress-argocd.yaml
pause "Application des fichiers YAML"

# Installation de ngrok
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
sudo apt update && sudo apt install ngrok
pause "Installation de ngrok"

# Démarrage de ngrok en arrière-plan
ngrok http 8080