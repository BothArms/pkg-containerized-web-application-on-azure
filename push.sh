docker build -t web-app ./app
docker tag web-app:latest containerregistrycwa.azurecr.io/web-app:latest
az acr login --name containerregistrycwa
docker push containerregistrycwa.azurecr.io/web-app:latest
