kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode
sleep 5
kubectl port-forward svc/argocd-server -n argocd 8080:443
