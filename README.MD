# Flask API Docker Deployment with Terraform and GitHub Actions

This project demonstrates a complete workflow to build, containerize, and deploy a Flask API using **Docker**, **Azure Container Registry (ACR)**, and **Azure App Service**. The infrastructure is managed using **Terraform**, and the Docker image build and push process is automated using **GitHub Actions**.

---

## Project Overview

This project covers:

1. **Docker Registry Creation**: Using Terraform to provision an Azure Container Registry (ACR).  
2. **CI/CD with GitHub Actions**: Automatically build, test, and push Docker images to ACR on every push to the `main` branch.  
3. **Application Deployment**: Deploy the Flask API container to Azure App Service using Terraform.

---

## Prerequisites

- Azure Subscription  
- GitHub repository  
- Terraform installed locally
- GitHub Secrets configured for ACR and Azure authentication  

Required **GitHub Secrets**:

| Secret Name | Purpose |
|------------|---------|
| `AZURE_CREDENTIALS` | JSON credentials for Azure login using `azure/login@v2` |
| `ACR_LOGIN_SERVER` | ACR login server (e.g., `flaskapiregistry2025.azurecr.io`) |
| `ACR_ADMIN_USERNAME` | Admin username for ACR |
| `ACR_ADMIN_PASSWORD` | Admin password for ACR |

---

## Steps to Run

### 1️⃣ Create Docker Registry (ACR)

1. Clone the repository
```bash
git clone <repository-url>
cd <repository-folder>
```

2. Navigate to the Terraform folder for Docker registry
```bash
cd infra/terraform/docker-registry
```

3. Create terraform.tfvars and fill the details

subscription_id = "XXXX"
client_id       = "XXXX"
client_secret   = "XXXX"
tenant_id       = "XXXX"

4. Execute the following commands to create Docker registry
```bash
terraform init
terraform plan -out my.plan
terraform apply "my.plan"
```
5. Get ACR admin user name and store
```bash
terraform output acr_admin_username
```
6. Get ACR admin password and store
```bash
terraform output acr_admin_password
```

- name: Azure Login
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

cred json format

{
  "clientId": "<YOUR-SERVICE-PRINCIPAL-CLIENT-ID>",
  "clientSecret": "<YOUR-SERVICE-PRINCIPAL-CLIENT-SECRET>",
  "subscriptionId": "<YOUR-AZURE-SUBSCRIPTION-ID>",
  "tenantId": "<YOUR-AZURE-TENANT-ID>"
}



az webapp create \
  --resource-group Azuredevops \
  --plan asp-flask-linux \
  --name flask-webapp-manu-app1 \
  --deployment-container-image-name flaskapiregistry2025.azurecr.io/flaskapp:latest


terraform output acr_admin_username
terraform output acr_admin_password





To troubleshoot whether your Azure Web App is pulling the container image successfully, follow these 5 verification steps.

✅ 1️⃣ Check Deployment Logs (Live streaming)

Run:

az webapp log tail -g Azuredevops -n flask-webapp-manu-app1


Signs the image failed to pull:

❌

Failed to pull image
unauthorized: authentication required
manifest unknown


Signs the image was pulled but app failed:

⚠️

Starting container...
Gunicorn started...
App crash...
Restarting...


Signs the image worked:

✔️

Pulling image succeeded.
Container started listening on 8000

✅ 2️⃣ Validate Container Settings in Web App

Check what Azure thinks your container is:

az webapp config container show \
  -g Azuredevops \
  -n flask-webapp-manu-app1


You should see:

{
  "dockerRegistryServerUrl": "flaskapiregistry2025.azurecr.io",
  "dockerCustomImageName": "flaskapiregistry2025.azurecr.io/flaskapp:latest"
}


If this is empty → Terraform didn’t apply correctly.

✅ 3️⃣ Test ACR Authentication

Test if the Web App identity can access ACR:

Run:

az acr repository list --name flaskapiregistry2025


Then check role assignment:

az role assignment list \
   --assignee $(az webapp identity show -g Azuredevops -n flask-webapp-manu-app1 --query principalId -o tsv) \
   --scope $(az acr show -n flaskapiregistry2025 --query id -o tsv)


You should see:

"AcrPull"


If empty → your Terraform role assignment did not apply.

✅ 4️⃣ Use the Built-In Container Startup Logs

Azure stores container runtime logs here:

🔍 Kudu/SCM console

Open:

https://flask-webapp-manu-app1.scm.azurewebsites.net/api/logs/docker


Or SSH:

az webapp ssh -g Azuredevops -n flask-webapp-manu-app1


Inside container check running processes:

ps aux


Check if image exists:

ls /var/lib/docker/images


If this folder is empty → container never pulled.

✅ 5️⃣ Enable Detailed Debug Logs

Add this to app settings:

app_settings = {
  WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  CONTAINER_LOGGING_ENABLED = "true"
  DOCKER_CUSTOM_IMAGE_RECEIVE_TIMEOUT = "600"
  WEBSITES_PORT = "8000"
}


Then restart:

az webapp restart -g Azuredevops -n flask-webapp-manu-app1

🔥 Most Common Issue in Your Terraform File

You are still using:

docker_registry_username = data.azurerm_container_registry.acr.admin_username
docker_registry_password = data.azurerm_container_registry.acr.admin_password


But admin_enabled = false, so this will break authentication.

Fix: Remove username/password and rely only on Role Assignment (Managed Identity).

✔ Final Fix in Terraform:
site_config {
  application_stack {
    docker_image_name = "${var.acr_name}.azurecr.io/${var.image_repository}:latest"
    docker_registry_url = "https://${data.azurerm_container_registry.acr.login_server}"
  }
}

Want me to generate the final cleaned-up working Terraform version? 🚀

I can include:

Health checks

Correct role assignment

Best practice environment variables

Working restart lifecycle

Would you like that? 💬
