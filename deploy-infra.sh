#!/bin/bash -e
echo "deploy-infra.sh is running"
echo "location (set by pipeline)=$location"
echo "resource group name (set by pipeline)=$rgName"
echo "app base name (set by pipeline)=$appBaseName"
acrName="${appBaseName}acr"
echo "acrName=$acrName"
planName="${appBaseName}-plan"
echo "planName=$planName"
webAppName="${appBaseName}-web"
echo "webAppName=$webAppName"

az acr create -l $location --sku basic --name $acrName --admin-enabled -g $rgName
acrUser=$(az acr credential show -n $acrName --query username -o tsv)
acrPassword=$(az acr credential show -n $acrName --query passwords[0].value -o tsv)
echo "[TEMPORARY]: created ACR $acrName (acrUser=$acrUser)"
az  appservice plan create -g $rgName --name $planName --location $location --number-of-workers 1 --sku S1 --is-linux
az webapp create \
  --name $webAppName \
  --plan $planName \
  --resource-group $rgName \
  --deployment-container-image-name "aztechcentralacr.azurecr.io/aztechcentralweb"
  --docker-registry-server-user $acrUser \
  --docker-registry-server-password $acrPassword \
az webapp log config --docker-container-logging filesystem  --name $webAppName --resource-group $rgName
