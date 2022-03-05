# mokrogopaya xD

Run with play

```sh
# Install Azure and login
az login
az account set --subscription "YOUR-SUBSC-ID"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/YOUR-SUBSC-ID"

# Copy ENV.dist and change values
cp .env.dist .env

# Init Terraform
terraform init
terraform fmt && terraform validate
terraform plan -out main.tfplan
terraform apply "main.tfplan"

# Copy IPs to the >> inventory/hosts.all
echo '[docker]' > inventory/hosts.all &&
  terraform output -raw ip >> inventory/hosts.all

./play docker.yml
```
