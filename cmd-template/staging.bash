# =============== drone ===============

# update staging settings
helm upgrade --install drone-svc . -f values/staging.yaml -f secrets/staging.yaml --namespace drone-svc --create-namespace

# force recreate pods
kubectl rollout restart deployment drone-svc -n drone-svc

# check release history
helm history drone-svc -n drone-svc


# =============== n8n ===============
# update n8n staging settings
helm upgrade --install n8n . -f values/staging.yaml -f secrets/staging.yaml --namespace n8n --create-namespace

# force recreate n8n pods
kubectl rollout restart deployment n8n -n n8n

# force recreate n8n-db pods
kubectl rollout restart deployment n8n-db -n n8n

# ===============ingress-controller ===============

# update ingress settings
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace -f ingress-controller/ingress-nginx-controller.yaml

# check release history
helm history -n ingress-nginx ingress-nginx





helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
# 去windows上的git bash做一次看能不能開驗證網頁
helm template postgres bitnami/postgresql   --kubeconfig "$HOME/.kube/config"   --namespace n8n   --set auth.username=n8n   --set auth.password=kLlyQTYN5JI8G4bVxBt7PKh37CYqq1Jd   --set auth.database=n8n
