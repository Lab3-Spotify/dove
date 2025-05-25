# =============== drone ===============

# update staging settings
helm upgrade --install drone .   -f values/staging.yaml   -f secrets/staging.yaml   --namespace drone --create-namespace

# force recreate pods
kubectl rollout restart deployment drone -n drone

# check release history
helm history drone -n drone


# ===============ingress-controller ===============

# update ingress settings
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace -f ingress-controller/ingress-nginx-controller.yaml

# check release history
helm history -n ingress-nginx ingress-nginx

