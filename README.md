# Validate managed identity + Key Vault reference for Azure Web App

This repo is a sample Azure deployment that validates **user-assigned managed identity** association with an Azure Web App, so the app can retrieve a Key Vault secret as an environment variable using a Key Vault reference.

It also includes **virtual network integration** between the Web App and Key Vault path used for secret retrieval:

- Web App VNet integration to a delegated subnet (`Microsoft.Web/serverFarms`)
- Subnet service endpoint for `Microsoft.KeyVault`
- Key Vault network ACL rule allowing that subnet

## Quick start

- See the full deployment and validation guide in [infra/README.md](infra/README.md).
- Deploy with `main.bicep` + `main.bicepparam` from the `infra` folder.
- Validate identity assignment, VNet integration, Key Vault network ACL, Key Vault RBAC, and app setting Key Vault reference resolution.
