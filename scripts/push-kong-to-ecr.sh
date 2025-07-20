ECR_REPO_URL="644789170005.dkr.ecr.ap-southeast-1.amazonaws.com"
ECR_REPO_NAME="kong"
VERSION="latest"

if [ -z "$ECR_REPO_URL" ]; then
    echo "Error: Repo not found"
    exit 1
fi

echo "ECR Repository URL: $ECR_REPO_URL"

aws ecr get-login-password --region ap-southeast-1 --profile bluebik | docker login --username AWS --password-stdin $ECR_REPO_URL

docker build -t kong:latest .

docker tag kong:$VERSION $ECR_REPO_URL/$ECR_REPO_NAME:$VERSION
docker push $ECR_REPO_URL/$ECR_REPO_NAME:$VERSION

echo "Image URL: $ECR_REPO_URL/$ECR_REPO_NAME:$VERSION" 