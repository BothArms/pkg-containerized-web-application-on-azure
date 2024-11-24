# Containerized Web Application on Azure

This project provides an optimized infrastructure for running a containerized web application on Azure.

![Azure Architecture](/docs/architecture.drawio.svg)

Key features include:

- **High Performance with Azure Container Apps**: Applications run in a fully managed environment with built-in scalability, load balancing, and HTTPS ingress.

- **Secure Infrastructure with Private Networking**:
  The infrastructure utilizes Azure Container Apps in private virtual networks, implements multi-layer security with subnet isolation and private endpoints, and maintains regular security patches through managed container updates.

- **Scalable Architecture with Auto Scaling**: The infrastructure leverages Azure Container Apps' built-in auto-scaling capabilities, automatically scaling containers based on HTTP traffic or custom metrics while maintaining high availability.

## Prerequisites

1. **Azure Account**: An active Azure subscription with appropriate permissions to create and manage resources.

2. **Azure CLI**: Install and configure the Azure CLI with your credentials.

   ```bash
   az login
   ```

3. **Node.js**: Install Node.js (version 18 or later) and npm.

   - Download from: https://nodejs.org/

4. **Docker**: Install Docker to build container images locally.

   - Download from: https://www.docker.com/get-started

5. **Bicep**: Install Bicep CLI for infrastructure deployment.

   ```bash
   az bicep install
   ```

## Getting Started

1. Comment out the `containerApps` resource in the `modules/container-apps.bicep` file.
2. Run `make deploy` to deploy the infrastructure.
3. Run `make push` to build and push the web-app image to the Azure Container Registry.
4. Uncomment the `containerApps` resource in the `modules/container-apps.bicep` file.
5. Run `make deploy` again to deploy the infrastructure with the container app.
