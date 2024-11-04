#!/bin/bash

# Supprimer le cluster k3d
k3d cluster delete mycluster

# Arrêter et supprimer les conteneurs Docker liés à k3d
docker ps -a | grep k3d | awk '{print $1}' | xargs -r docker stop
docker ps -a | grep k3d | awk '{print $1}' | xargs -r docker rm

# Supprimer les images Docker liées à k3d
docker images | grep k3d | awk '{print $3}' | xargs -r docker rmi

# Arrêter ngrok s'il est en cours d'exécution
pkill ngrok

echo "Nettoyage terminé."