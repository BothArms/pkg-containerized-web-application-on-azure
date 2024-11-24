# 1. Build local image
docker build -t myapp:1.0 .

# 2. Tag for ACR
docker tag myapp:1.0 containerizedwebapplication2.azurecr.io/myapp:1.0

# 3. Push to ACR
docker push containerizedwebapplication2.azurecr.io/myapp:1.0