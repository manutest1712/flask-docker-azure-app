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
