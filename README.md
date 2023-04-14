## Deploy FastAPI on Cloud Run (Beginner)

<div>
    <img src="https://readme-typing-svg.demolab.com/?pause=1&size=50&color=f75c7e&center=True&width=1200&height=120&vCenter=True&lines=Click+the+⭐+Star+please.;Any+questions+can+be+asked+in+Discussion." />
</div>

## Introduction

* Template for running FastAPI on Google Cloud Run.

* Deploying API on Cloud Run with FastAPI in one-click and quickly.

## Basic method via CLI

* `gcloud CLI`
    * **Build Image on Cloud (Container Registry)**
        ```
        gcloud builds submit --tag {REGION}.gcr.io/{PROJECT_ID}/{IMAGE} --ignore-file .gcloudignore
        ```
    
    * **Deploy Service to Cloud Run***
        ```
        gcloud run deploy --image {REGION}.gcr.io/{PROJECT_ID}/{IMAGE} --platform managed --port 8000 --memory {1Gi} --timeout={2m}
        ```

## Advance method via Shell

#### advantage

* **Automation**: By using these tools, you can automate the process of deploying resources and infrastructure, which saves time and reduces the potential for human error.

* **Consistency**: Automation ensures that the deployment process is consistent across environments, which makes it easier to manage and troubleshoot issues.

* **Reusability**: With Cloud Deployment Manager or shell script, you can reuse templates and scripts to deploy the same resources and infrastructure multiple times, making it more efficient to set up new environments.

* **Scalability**: These tools enable you to deploy resources and infrastructure at scale, which is especially useful for large-scale projects.

* **Version control**: By storing the templates and scripts in version control, you can track changes and roll back to a previous version if necessary.

#### how it work ?

In our [`deploy.sh`](./deploy.sh) we will:

1. Get ENV from [`config.env`](./config.env)
    ```
    source config.env
    ```            
2. Enable GCP services
    ```
    gcloud services enable cloudbuild.googleapis.com storage-component.googleapis.com containerregistry.googleapis.com run.googleapis.com
    ```
3. Build image to container registry
    ```
    gcloud builds submit --tag "$CONTAINER_HOST/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG" --ignore-file .gcloudignore
    ```
4. Deploy service to cloud run
    ```
    gcloud run deploy $SERVICE_NAME --image "$CONTAINER_HOST/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG" --platform managed --port "$PORT" --memory "$MEMORY" --timeout="$TIMEOUT" --region="$REGION"
    ```
    * You can use `gcloud run deploy --help` to check all `FLAGS`, <a href="https://cloud.google.com/sdk/gcloud/reference/run/deploy">see</a>

    * If you won't any one access this api, you should remove `--allow-unauthenticated` from [`deploy.sh`](./deploy.sh), [see Authenticated]()

#### method
1. Define your **"ENVIRONMENT VARIABLES"** in [`config.env`](./config.env), for example:

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
2. Define your application (FastAPI) in `main.py` and `routers/`

3. Define the required modules in `requirements.txt`

    * Here an simple way to collect all modules used from `.py`
        Execute the following CLI in `cmd`, `powershell`, `wsl`, `git bash`, ...
        ```
        pip install pipreqs
        ```
        ```
        pipreqs ./
        ```

4. Check your `Dockerfile`

5. Deploy your application:
    Execute the following CLI in `wsl`, `git bash`, ...
    ```
    ./deploy.sh
    ```


#### Demo
1. Clone the project using Git.

2. Open a terminal and navigate to the project directory.

3. Run the `./deploy.sh` script.

4. Wait for the deployment to finish and get the **Service URL**, for example: `https://service-template-xxxxxxxxxx-xx.a.run.app`

5. Use the [`client.py`](./client/) script to test your API, for example:

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

#### Authenticated

* **Authenticated** is a security option in Cloud Run that controls who can access your application.

    * `--no-allow-unauthenticated` : no one can access your api.

        * [How to grant authorization to specific members?](https://cloud.google.com/sdk/gcloud/reference/run/services/add-iam-policy-binding)

            ```
            gcloud run services add-iam-policy-binding my-service --region='us-central1' --member='user:test-user@gmail.com' --role='roles/run.invoker'
            ```

    * `--allow-unauthenticated` : any one can access your api