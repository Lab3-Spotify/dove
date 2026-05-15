HELM_REPOS := \
	cloudflare=https://cloudflare.github.io/helm-charts \
	ingress-nginx=https://kubernetes.github.io/ingress-nginx

.PHONY: repos

repos:
	@existing=$$(helm repo list -o json 2>/dev/null | grep -o '"name":"[^"]*"' | cut -d'"' -f4); \
	missing=false; \
	for repo in $(HELM_REPOS); do \
		name=$${repo%%=*}; \
		url=$${repo##*=}; \
		if ! echo "$$existing" | grep -qx "$$name"; then \
			echo "==> [repo] adding $$name"; \
			helm repo add $$name $$url; \
			missing=true; \
		else \
			echo "==> [repo] $$name already exists, skipping"; \
		fi; \
	done; \
	if [ "$$missing" = true ]; then helm repo update; fi
