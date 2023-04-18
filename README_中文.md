## 在 Cloud Run 上部署 FastAPI (初學者)

* 本文的主要專案請[參閱](https://github.com/Lin-jun-xiang/cloudrun-fastapi-simple)
* 詳細範例檔案、文章描述皆在 [GitHub](https://github.com/Lin-jun-xiang/cloudrun-fastapi-simple) 專案中

## 簡介

* 在 Google Cloud Run 上運行 FastAPI 的範本

* 透過一鍵式且快速地使用 FastAPI 在 Cloud Run 上部署 API

## 透過 CLI 的基本方法

* `gcloud CLI`
    * **在雲端上建立映像檔 (容器登記)**
        ```
        gcloud builds submit --tag {REGION}.gcr.io/{PROJECT_ID}/{IMAGE} --ignore-file .gcloudignore
        ```
    
    * **部署服務至 Cloud Run**
        ```
        gcloud run deploy --image {REGION}.gcr.io/{PROJECT_ID}/{IMAGE} --platform managed --port 8000 --memory {1Gi} --timeout={2m}
        ```

## 透過 Shell 的進階方法

#### 優點

* **自動化**: 透過使用這些工具，您可以自動化部署資源與基礎架構的流程，節省時間並減少人為失誤的機會

* **一致性**: 自動化確保了部署流程在各種環境中都是一致的，這使得管理和疑難排解更加容易

* **可重複使用**: 透過 Cloud Deployment Manager 或 shell script，您可以重複使用範本和腳本來多次部署相同的資源和基礎架構，進而提高建立新環境的效率

* **擴展性**: 這些工具讓您可以擴展部署大規模專案所需的資源與基礎架構，尤其適用於大型專案

* **版本控制**: 透過將範本和腳本儲存在版本控制中，您可以追蹤變更並在必要時回到先前的版本

#### 工作方式

在我們的 `deploy.sh` 中，我們將:

1. 從 `config.env` 取得環境變數
    ```
    source config.env
    ```            
2. 啟用 GCP 服務
    ```
    gcloud services enable cloudbuild.googleapis.com storage-component.googleapis.com containerregistry.googleapis.com run.googleapis.com
    ```
3. 將映像檔建置至容器登記
    ```
    gcloud builds submit --tag "$CONTAINER_HOST/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG" --ignore-file .gcloudignore
    ```
4. 部署到 Cloud Run
    ```
    gcloud run deploy $SERVICE_NAME --image "$CONTAINER_HOST/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG" --platform managed --port "$PORT" --memory "$MEMORY" --timeout="$TIMEOUT" --region="$REGION"
    ```
    * 您可以使用 `gcloud run deploy --help` 檢查所有的 FLAGS，[參閱](https://cloud.google.com/sdk/gcloud/reference/run/deploy) 

    * 如果您不希望任何人訪問此 API，您應該從 `deploy.sh` 中刪除 `--allow-unauthenticated`，參閱[驗證](#驗證)

#### 一鍵部署方式
1. 在 `config.env` 中定義您的 "**環境變數**"，例如：

    ```
    PROJECT_ID="GCP-PROJECT-ID"

    IMAGE_NAME="service-template"
    IMAGE_TAG="latest"

    CONTAINER_HOST="asia.gcr.io"
    SERVICE_NAME="service-template"
    REGION="asia-east1"
    PORT=8000
    MEMORY="1Gi"
    TIMEOUT="2m"
    ```
2. 在 `main.py` 和 `routers/` 中定義您的應用程式（FastAPI）。

3. 在 `requirements.txt` 中定義所需的模組

    * 以下是從 `.py` 中收集所有使用模組的簡單方法，在 `cmd、powershell、wsl、git bash` 中執行以下 CLI
        ```
        pip install pipreqs
        ```
        ```
        pipreqs ./
        ```

4. 檢查您的  `Dockerfile`

5. 部署您的應用程式：
    在 `wsl、git bash` 中執行以下 CLI
    ```
    ./deploy.sh
    ```


#### 示範
1. 使用 Git 複製此專案

2. 打開終端機，並導覽到此專案目錄

3. 執行 `./deploy.sh` 指令

4. 等待部署完成，並取得 `Service URL`，例如：`https://service-template-xxxxxxxxxx-xx.a.run.app`

5. 使用 `client.py` 腳本測試您的 API，例如：

    ### Script
    ```python
    import requests

    host = "Service URL"
    url = f"{host}/v1/recommend"

    request_data = {
                    "page": "index",
                    "data": {"ip_address": "e12345"}
    }

    res = requests.post(url, json=request_data)

    if res.status_code == 200:
        print(res.json())
    else:
        print("Error: ", res.text)
    ```

    ### Result
    ```
    {'code': '0', 'msg': 'success', 'ip_address': 'e12345'}
    ```

#### 驗證

* 驗證是 Cloud Run 中的安全選項，用於控制誰可以訪問您的應用程式

    * `--no-allow-unauthenticated` : 任何人都不可訪問 api

        * [允許限定的成員可訪問](https://cloud.google.com/sdk/gcloud/reference/run/services/add-iam-policy-binding)

            ```
            gcloud run services add-iam-policy-binding my-service --region='us-central1' --member='user:test-user@gmail.com' --role='roles/run.invoker'
            ```

    * `--allow-unauthenticated` : 任何人都可以訪問 api