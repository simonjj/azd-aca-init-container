# Azure Container Apps Init Container Example

A simple Azure Developer CLI (azd) template demonstrating how to deploy multiple containers to Azure Container Apps, including an init container pattern.

## Project Structure

- `azure.yaml` - Azure Developer CLI configuration
- `infra/` - Bicep infrastructure templates
- `src/init-app/` - Init container (Alpine-based)
- `src/my-app/` - Main application container (Python Flask)

## Prerequisites

- [Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)
- [Docker](https://docs.docker.com/get-docker/)
- Azure subscription

## Getting Started

1. Clone this repository
2. Run `azd auth login` to authenticate with Azure
3. Run `azd up` to provision and deploy the application

## Architecture

This template provisions:
- Azure Container Registry (ACR) for storing container images
- Azure Container Apps Environment
- Azure Container App with both init and main containers

The init container runs first to perform any setup tasks, followed by the main Python Flask application.

## Local Development

To test the containers locally:

```bash
# Build and test the init container
docker build -t test-init-app ./src/init-app
docker run test-init-app

# Build and test the main app
docker build -t test-my-app ./src/my-app
docker run -p 5000:5000 test-my-app
```