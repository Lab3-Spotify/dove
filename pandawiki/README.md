# PandaWiki Helm Chart

這是為 [PandaWiki](https://github.com/chaitin/PandaWiki) 設計的 Helm Chart，PandaWiki 是一款 AI 大模型驅動的開源知識庫搭建系統。

## 架構說明

本 Helm Chart 包含以下組件：

- **PandaWiki 主服務**: 提供 Web UI 和 API 服務
- **PostgreSQL 資料庫**: 儲存知識庫資料
- **Ingress**: 提供 HTTPS 訪問
- **Persistent Volume**: 確保資料持久化

## 快速開始

### 前置需求

- Kubernetes 集群
- Helm 3.x
- cert-manager (用於 SSL 證書)
- nginx-ingress-controller

### 部署步驟

1. **修改配置**
   
   編輯 `values/staging.yaml` 檔案，根據您的環境調整配置：
   - 修改 `host` 為您的域名
   - 調整資源配置
   - 配置 AI 模型相關設定

2. **配置 Gemini API Key**
   
   編輯 `secrets/staging.yaml` 檔案，設置您的 Gemini API Key：
   ```yaml
   # Gemini AI 模型配置
   GEMINI_API_KEY: your-actual-gemini-api-key-here
   GEMINI_BASE_URL: https://generativelanguage.googleapis.com
   ```

3. **部署服務**

   ```bash
   # 安裝
   ./cmd-template/pandawiki.bash install
   
   # 升級
   ./cmd-template/pandawiki.bash upgrade
   
   # 卸載
   ./cmd-template/pandawiki.bash uninstall
   ```

4. **配置 AI 模型**

   首次訪問時，您需要配置 AI 模型才能使用 AI 功能：
   - 推薦使用 [百智雲模型廣場](https://www.baizhi.cloud/)
   - 或配置其他支援的 AI 模型，如 Gemini

## 配置說明

### 主要配置項目

- `pandawiki.image`: PandaWiki 容器映像
- `pandawiki.ingress.host`: 訪問域名
- `pandawiki.storage`: 資料持久化配置
- `db.image`: PostgreSQL 資料庫映像
- `db.persistence`: 資料庫持久化配置

### 環境變數

主要環境變數包括：
- `PANDAWIKI_PORT`: 服務端口 (預設: 2443)
- `PANDAWIKI_HOST`: 服務主機 (預設: 0.0.0.0)
- `DB_TYPE`: 資料庫類型 (預設: postgresdb)
- `DB_POSTGRESDB_HOST`: 資料庫主機
- `DB_POSTGRESDB_PORT`: 資料庫端口

### Gemini AI 配置

要使用 Gemini AI 模型，需要在 `secrets/staging.yaml` 中配置：

```yaml
# Gemini AI 模型配置
GEMINI_API_KEY: your-gemini-api-key-here
GEMINI_BASE_URL: https://generativelanguage.googleapis.com
```

**獲取 Gemini API Key 步驟：**
1. 訪問 [Google AI Studio](https://makersuite.google.com/app/apikey)
2. 登入您的 Google 帳號
3. 點擊 "Create API Key" 創建新的 API Key
4. 複製 API Key 並填入配置檔案

## 訪問方式

部署完成後，您可以通過以下方式訪問：

- **控制台**: https://your-domain.com (管理介面)
- **Wiki 網站**: 在控制台中創建知識庫後自動生成

## 故障排除

### 常見問題

1. **服務無法啟動**
   - 檢查 Pod 日誌: `kubectl logs -n pandawiki deployment/pandawiki`
   - 確認資料庫連接正常

2. **無法訪問網站**
   - 檢查 Ingress 配置
   - 確認 DNS 解析正確
   - 檢查 SSL 證書狀態

3. **AI 功能無法使用**
   - 確認已配置 AI 模型
   - 檢查 API Key 是否正確
   - 確認 Gemini API Key 有效且未過期

### 日誌查看

```bash
# 查看 PandaWiki 日誌
kubectl logs -n pandawiki deployment/pandawiki

# 查看資料庫日誌
kubectl logs -n pandawiki statefulset/pandawiki-db

# 查看 Ingress 日誌
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

## 備份與恢復

### 資料備份

```bash
# 備份資料庫
kubectl exec -n pandawiki statefulset/pandawiki-db -- pg_dump -U pandawiki pandawiki > backup.sql

# 備份持久化資料
kubectl cp pandawiki/pandawiki-0:/app/data ./pandawiki-backup
```

### 資料恢復

```bash
# 恢復資料庫
kubectl exec -i -n pandawiki statefulset/pandawiki-db -- psql -U pandawiki pandawiki < backup.sql
```

## 版本更新

更新 PandaWiki 版本：

1. 修改 `values/staging.yaml` 中的 `tag` 版本
2. 執行升級命令：
   ```bash
   ./cmd-template/pandawiki.bash upgrade
   ```

## 參考資料

- [PandaWiki 官方文檔](https://pandawiki.docs.baizhi.cloud/)
- [PandaWiki GitHub](https://github.com/chaitin/PandaWiki)
- [Google AI Studio](https://makersuite.google.com/app/apikey)
- [Helm 文檔](https://helm.sh/docs/) 