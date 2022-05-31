#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo -e "\n\e[34m╔══════════════════════════════════╗"
echo -e "║\e[32m    Terraform Init "${BASH_SOURCE[0]}" 🚀\e[34m    ║"
echo -e "╚══════════════════════════════════╝"
echo -e "\n\e[34m»»» ✅ \e[96mChecking pre-reqs\e[0m..."

# Check Azure CLI and Terraform are installed
az > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo -e "\e[31m»»» ⚠️  Azure CLI is not installed! 😥 Please go to http://aka.ms/cli to set it up"
  exit
fi

terraform version > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo -e "\e[31m»»» ⚠️  Terraform is not installed! 😥 Please go to https://www.terraform.io/downloads.html to set it up"
  exit
fi

# Check Azure CLI is logged in
export SUB_NAME=$(az account show --query name -o tsv)
if [[ -z $SUB_NAME ]]; then
  echo -e "\n\e[31m»»» ⚠️  You are not logged in to Azure!"
  exit
fi
export TENANT_ID=$(az account show --query tenantId -o tsv)

# Confirm Azure account details are correct
echo -e "\e[34m»»» 🔨 \e[96mAzure details from logged on user \e[0m"
echo -e "\e[34m»»»   • \e[96mSubscription: \e[33m$SUB_NAME\e[0m"
echo -e "\e[34m»»»   • \e[96mTenant:       \e[33m$TENANT_ID\e[0m\n"

read -p " - Are these details correct, do you want to continue (y/n)? " answer
case ${answer:0:1} in
    y|Y )
    ;;
    * )
        echo -e "\e[31m»»» 😲 Deployment canceled\e[0m\n"
        exit
    ;;
esac

echo -e "\n\e[34m»»» ✨ \e[96mTerraform Init\e[0m..."
terraform init
sam@Azure:~/git/terraform$ 
