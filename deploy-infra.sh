#!/bin/bash -e
echo "deploy-infra.sh is running"
echo "location (set by pipeline)=$LOCATION"
echo "resource group name (set by pipeline)=$RG_NAME"
echo "insane alias (set by pipeline)=$INSANE_ALIAS"
acrName="${INSANE_ALIAS}acr"
echo "acrName=$acrName"
planName="${INSANE_ALIAS}-plan"
echo "planName=$planName"
webAppName="${INSANE_ALIAS}-web"
echo "webAppName=$webAppName"

az acr create -l $LOCATION --sku basic --name $acrName --admin-enabled -g $RG_NAME
acrUser=$(az acr credential show -n $acrName --query username -o tsv)
acrPassword=$(az acr credential show -n $acrName --query passwords[0].value -o tsv)
echo "[TEMPORARY]: created ACR $acrName (acrUser=$acrUser)"
az  appservice plan create -g $RG_NAME --name $planName --location $LOCATION --number-of-workers 1 --sku S1 --is-linux
az webapp create \
  --name $webAppName \
  --plan $planName \
  --resource-group $RG_NAME \
  #--deployment-container-image-name "aztechcentralacr.azurecr.io/aztechcentralweb"
  --docker-registry-server-user $acrUser \
  --docker-registry-server-password $acrPassword \
az webapp log config --docker-container-logging filesystem  --name $webAppName --resource-group $RG_NAME
