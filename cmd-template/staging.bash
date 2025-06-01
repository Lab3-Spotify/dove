# =============== drone server ===============

# update staging settings
helm upgrade --install drone-svc . -f values/staging.yaml -f secrets/staging.yaml --namespace drone --create-namespace

# force recreate pods
kubectl rollout restart deployment drone-svc -n drone

# check release history
helm history drone-svc -n drone

# set up local-path
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

# check local-path pods
kubectl get pods -n local-path-storage


# 刪除DB pvc
kubectl delete pvc -l app=drone-svc-db -n drone





# =============== drone runner ===============

# update staging settings
helm upgrade --install drone-runner . -f values/staging.yaml -f secrets/staging.yaml --namespace drone --create-namespace

# force recreate pods (each repo has its own deployment)
kubectl rollout restart deployment drone-runner-walrus -n drone

# check release history
helm history drone-runner-walrus -n drone

# note: 記得去github上綁drone的webhook
# https://lab3-drone.ddns.net/hook 









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






# =============== walrus ===============
# update n8n staging settings
helm upgrade --install walrus . -f values/staging.yaml -f secrets/staging.yaml --namespace walrus --create-namespace

# force recreate walrus pods
kubectl rollout restart deployment walrus -n walrus

# force recreate walrus-db pods
kubectl rollout restart deployment walrus-db -n walrus

# force recreate walrus-redus pods
kubectl rollout restart deployment walrus-redis -n walrus




# =============== HTTPS ===============

# 部署 證書請求服務
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml

# 查看 證書請求服務
kubectl get pods -n cert-manager

# 部署 cert-manager
kubectl apply -f clusterissuer.yaml

# 查看 cert-manager
kubectl get clusterissuer









# =============== 權限設置 ===============

# 建立新的權限帳號(在 drone namespace)
kubectl create serviceaccount drone-dove-runner -n drone

# 建立權限
kubectl create clusterrolebinding drone-walrus-runner-admin   --clusterrole=cluster-admin   --serviceaccount=drone:drone-walrus-runner

# 賦予一個sa某個ns的大部分權力
kubectl create rolebinding runner-walrus-edit --namespace=walrus --clusterrole=edit --serviceaccount=drone:drone-walrus-runner



# 建立一個超級帳號(因為ns在kube-system)
kubectl -n kube-system create serviceaccount drone-ci

# 授權所有ns的所有操作權
kubectl create clusterrolebinding drone-ci-cluster-admin-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=kube-system:drone-ci

# 獲取帳號的臨時token，後續無法查看
kubectl create token drone-ci -n kube-system

# 查看帳號的CA
kubectl config view --raw --minify --flatten \
  -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' \
  | base64 -d

# 查看cluster host
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'

# 為超級帳號建立永久token
kubectl apply -f authorize-drone-ci.yaml

# 查看永久token
kubectl get secret drone-ci-token -n kube-system -o jsonpath="{.data.token}" | base64 --decode


# 檢查一個帳號在所有namespace下的權限
# 假設 ServiceAccount 在 walrus namespace

# SA="system:serviceaccount:[USER在的NAMESPACE]:[USERNAME]"
SA="system:serviceaccount:walrus:drone-ci"
NS="walrus"

echo "===== 檢查 drone-ci 在 namespace 'walrus' 下對 ConfigMap 的權限 ====="
for verb in get list watch create update patch delete; do
  printf "%-6s configmaps? ▶ " "$verb"
  kubectl auth can-i $verb configmaps --namespace=$NS --as=$SA
done

echo
echo "===== 檢查 drone-ci 在 namespace 'walrus' 下對 Deployment 的權限 ====="
for verb in get list watch create update patch delete; do
  printf "%-6s deployments? ▶ " "$verb"
  kubectl auth can-i $verb deployments --namespace=$NS --as=$SA
done

echo
echo "===== 檢查 drone-ci 在 namespace 'walrus' 下對 Pods 的權限 ====="
for verb in get list watch create update patch delete; do
  printf "%-6s pods? ▶ " "$verb"
  kubectl auth can-i $verb pods --namespace=$NS --as=$SA
done