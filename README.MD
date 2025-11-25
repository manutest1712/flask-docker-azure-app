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

```hcl
subscription_id = "XXXX"
client_id       = "XXXX"
client_secret   = "XXXX"
tenant_id       = "XXXX"
```

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

---

### 2️⃣ Build and Publish Docker Image using GitHub Actions

1. Set Secret values for GitHub Actions:
- AZURE_CREDENTIALS

```hcl
{
  "clientId": "<YOUR-SERVICE-PRINCIPAL-CLIENT-ID>",
  "clientSecret": "<YOUR-SERVICE-PRINCIPAL-CLIENT-SECRET>",
  "subscriptionId": "<YOUR-AZURE-SUBSCRIPTION-ID>",
  "tenantId": "<YOUR-AZURE-TENANT-ID>"
}
```

- ACR_LOGIN_SERVER
- ACR_ADMIN_USERNAME
- ACR_ADMIN_PASSWORD

2. GitHub Actions workflow location:
```bash
.github/workflows/docker-build.yml
```
3. Execute the work flow
Push a commit to the branch configured in the workflow (e.g., main) or trigger it manually from the GitHub Actions tab.

---

### 3️⃣ Deploy Flask App to Azure App Service

1. Navigate to the Terraform folder for App deployment
```bash
cd infra/terraform/app-deployment
```

3. Create terraform.tfvars and fill the details

```hcl
subscription_id = "XXXX"
client_id       = "XXXX"
client_secret   = "XXXX"
tenant_id       = "XXXX"
acr_admin_username = "XXX"
acr_admin_password = "XXX"
```

4. Execute the following commands to to deploy the app
```bash
terraform init
terraform plan -out my.plan
terraform apply "my.plan"
```
5. Verify the deployment
- Check in the Azure Portal that the App Service is running
- Test the API endpoint using curl:

```bash
curl -f https://<server url>/api/v1/Books
```

---


