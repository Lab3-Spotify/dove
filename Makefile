HELM_REPOS := \
	cloudflare=https://cloudflare.github.io/helm-charts \
	ingress-nginx=https://kubernetes.github.io/ingress-nginx \
	glitchtip=https://gitlab.com/api/v4/projects/16325141/packages/helm/stable \
	bitnami=https://charts.bitnami.com/bitnami

CHARTS_WITH_DEPS := glitchtip

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
	@for chart in $(CHARTS_WITH_DEPS); do \
		echo "==> [deps] updating $$chart"; \
		helm dependency update ./$$chart; \
	done
