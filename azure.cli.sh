# create shell variables

resourceGroup=ddosgroup
instlocation=eastus


az group create --name $resourceGroup --location eastus

az network vnet create \
  --name revennet3 \
  --resource-group $resourceGroup \
  --address-prefixes 10.2.0.0/16 \
  --subnet-name revensubnet3 \
  --subnet-prefixes 10.2.0.0/24
az network vnet create \
  --name revennet1 \
  --resource-group $resourceGroup \
  --address-prefixes 10.0.0.0/16 \
  --subnet-name revensubnet1 \
  --subnet-prefixes 10.0.0.0/24
az network vnet create \
  --name revennet2 \
  --resource-group $resourceGroup \
  --address-prefixes 10.1.0.0/16 \
  --subnet-name revensubnet2 \
  --subnet-prefixes 10.1.0.0/24
az vm create \
   --resource-group $resourceGroup \
   --name revenvm1 \
   --image OpenLogic:CentOS:7.4:latest \
   --vnet-name revennet1 \
   --subnet revensubnet1 \
   --admin-username alex \
   --admin-password my-super-puper-password \
   --output json \
   --verbose
az vm create \
   --resource-group $resourceGroup \
   --name revenvm2 \
   --image OpenLogic:CentOS:7.4:latest \
   --vnet-name revennet2 \
   --subnet revensubnet2 \
   --admin-username alex \
   --admin-password my-super-puper-password \
   --output json \
   --verbose
az vm create \
   --resource-group $resourceGroup \
   --name revenvm3 \
   --image OpenLogic:CentOS:7.4:latest \
   --vnet-name revennet3 \
   --subnet revensubnet3 \
   --admin-username alex \
   --admin-password my-super-puper-password \
   --output json \
   --verbose

echo "[docker]" > host.txt
az network public-ip list | grep ipAd | grep -v null | awk -F ":" '{print $2}' | cut -c 3- | rev | cut -c 3- | rev >> host.txt
sleep 3800
az group delete -g ddosgroup
