#!/bin/bash

# Fonction pour ajouter une pause et afficher un message
pause() {
    echo "Étape terminée : $1"
    sleep 5
    echo "Passage à l'étape suivante..."
}

# Supprimer le cluster k3d
k3d cluster delete mycluster
pause "Suppression du cluster k3d"

# Arrêter et supprimer les conteneurs Docker liés à k3d
docker ps -a | grep k3d | awk '{print $1}' | xargs -r docker stop
docker ps -a | grep k3d | awk '{print $1}' | xargs -r docker rm
pause "Nettoyage des conteneurs Docker"

# Supprimer les images Docker liées à k3d
docker images | grep k3d | awk '{print $3}' | xargs -r docker rmi
pause "Suppression des images Docker"

# Arrêter ngrok
pkill ngrok
pause "Arrêt de ngrok"

# Supprimer les fichiers YAML créés
rm -f app-argo-cd.yaml ingress-app.yaml ingress-argocd.yaml
pause "Suppression des fichiers YAML"

# Désinstaller les outils installés (optionnel, décommentez si nécessaire)
# sudo apt-get remove -y docker.io kubectl ngrok jq
# sudo apt-get autoremove -y
# pause "Désinstallation des outils"

# Supprimer les configurations de ngrok
rm -rf ~/.ngrok2
pause "Suppression des configurations ngrok"

echo "Nettoyage terminé !"
