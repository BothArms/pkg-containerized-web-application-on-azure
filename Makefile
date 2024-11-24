# Note: If you want to change the project name or container name, you need to update the main.bicep file and the Makefile

# Build and push the web-app image to the Azure Container Registry
push:
	docker build -t web-app ./app
	docker tag web-app:latest containerregistrycwa.azurecr.io/web-app:latest
	az acr login --name containerregistrycwa
	docker push containerregistrycwa.azurecr.io/web-app:latest

# Deploy the Bicep template to create the Azure resources
deploy:
	az deployment sub create --location japaneast --template-file main.bicep
