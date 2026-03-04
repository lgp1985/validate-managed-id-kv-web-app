# Validate managed identity + Key Vault reference for Azure Web App

This repo is a sample Azure deployment that validates **user-assigned managed identity** association with an Azure Web App, so the app can retrieve a Key Vault secret as an environment variable using a Key Vault reference.

## Quick start

- See the full deployment and validation guide in [infra/README.md](infra/README.md).
- Deploy with `main.bicep` + `main.bicepparam` from the `infra` folder.
- Validate identity assignment, Key Vault RBAC, and app setting Key Vault reference resolution.
