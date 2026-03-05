# Validate managed identity + Key Vault reference for Azure Web App

This repository is a **sample Bicep deployment** that validates a user-assigned managed identity association with an Azure Web App, so the app can resolve a Key Vault secret through an app setting (environment variable).

It also validates the **virtual network integration path** used for Web App to Key Vault communication when resolving the secret reference.

## What this deployment creates

- Resource group (subscription-scope deployment)
- Azure Key Vault (RBAC enabled)
- One Key Vault secret with a known value
- Virtual network + delegated subnet for App Service VNet integration
- Subnet service endpoint for `Microsoft.KeyVault`
- App Service Plan (Linux, Basic B1)
- User-assigned managed identity
- Azure Web App (Linux .NET 8)
- Role assignment: **Key Vault Secrets User** for the user-assigned identity on the Key Vault

The Web App is configured with:

- `identity.type = UserAssigned`
- `keyVaultReferenceIdentity = <user-assigned-identity-resource-id>`
- `virtualNetworkSubnetId = <delegated-subnet-resource-id>`

The Key Vault is configured with network ACLs to allow traffic from that subnet (`defaultAction = Deny` with `virtualNetworkRules` set to the Web App integration subnet).

This is the core configuration required for Key Vault references to resolve using that identity.

## Files

- `main.bicep`: subscription-scope entry point
- `deployment.bicep`: resource definitions
- `main.bicepparam`: sample parameter values

## Prerequisites

- Azure CLI (latest)
- Bicep CLI (`az bicep install`)
- Permissions to deploy at subscription scope and assign roles
- Logged in to Azure: `az login`

## Deploy

From the `infra` folder, first run a preview:

```bash
az deployment sub what-if \
 --name validate-managed-id-kv-webapp \
 --location eastus2 \
 --template-file main.bicep \
 --parameters main.bicepparam
```

Then run the deployment:

```bash
az deployment sub create \
 --name validate-managed-id-kv-webapp \
 --location eastus2 \
 --template-file main.bicep \
 --parameters main.bicepparam
```

## Validate identity association, network integration, and access

Use values from `main.bicepparam` (or your own overrides).

1. Confirm the Web App has the user-assigned identity:

```bash
az webapp identity show \
 --resource-group rg-lg-temp1 \
 --name web-temp1
```

1. Confirm the Web App is integrated with the expected subnet:

```bash
az webapp show \
 --resource-group rg-lg-temp1 \
 --name web-temp1 \
 --query "virtualNetworkSubnetId" -o tsv
```

1. Confirm Key Vault allows the expected subnet in `networkAcls.virtualNetworkRules`:

```bash
az keyvault show \
 --name kv-temp1 \
 --query "properties.networkAcls.virtualNetworkRules[].id" -o tsv
```

1. Confirm the Key Vault RBAC role assignment exists for that identity:

```bash
az role assignment list \
 --scope $(az keyvault show --name kv-temp1 --query id -o tsv) \
 --assignee-object-id $(az identity show --resource-group rg-lg-temp1 --name uai-temp1 --query principalId -o tsv) \
 --query "[].{role:roleDefinitionName,principalId:principalId}" -o table
```

Expected role includes `Key Vault Secrets User`.

## Use secret as an environment variable (app setting)

Set a Key Vault reference as an app setting:

```bash
az webapp config appsettings set \
 --resource-group rg-lg-temp1 \
 --name web-temp1 \
 --settings "MY_SECRET=@Microsoft.KeyVault(SecretUri=https://kv-temp1.vault.azure.net/secrets/secret-temp1/)"
```

Restart the app so reference resolution is refreshed:

```bash
az webapp restart --resource-group rg-lg-temp1 --name web-temp1
```

In your app code, read `MY_SECRET` like a normal environment variable.

## Notes

- In this sample, parameter name `KnwonValue` is intentionally kept as-is to match the current Bicep files.
- Propagation for RBAC and identity changes can take a few minutes.
- If resolution fails, verify:
  - Web App identity includes the expected user-assigned identity
  - `keyVaultReferenceIdentity` points to that same identity
  - `virtualNetworkSubnetId` points to the intended delegated subnet
  - Key Vault `networkAcls` includes that subnet in `virtualNetworkRules`
  - Role assignment is on the correct Key Vault scope
