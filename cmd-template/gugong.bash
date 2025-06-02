# =============== open-webui ===============
# update n8n staging settings
helm upgrade --install webui . -f values/staging.yaml -f secrets/staging.yaml --namespace webui --create-namespace

# force recreate n8n pods
kubectl rollout restart deployment webui -n webui

# force recreate n8n-db pods
kubectl rollout restart deployment webui-db -n webui