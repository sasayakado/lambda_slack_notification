#!/bin/bash
set -e

# ./.envファイルを読み込んで変数として参照できるようにする
source ./.env

# 既存のコンテナが存在するか確認
EXISTING_CONTAINER=$(docker ps -aqf "name=$DOCKER_CONTAINER_NAME")

# 既存のコンテナが存在すれば停止 & 削除
if [ ! -z "$EXISTING_CONTAINER" ]; then
    echo "Removing existing container..."
    docker stop $EXISTING_CONTAINER
    docker container rm $EXISTING_CONTAINER
fi

# 既存のイメージが存在するか確認
EXISTING_IMAGE=$(docker image ls -q $DOCKER_IMAGE_NAME:$IMAGE_TAG)

# 既存のイメージが存在すれば削除
if [ ! -z "$EXISTING_IMAGE" ]; then
    echo "Removing existing image..."
    docker image rm -f $EXISTING_IMAGE
fi

# docker-composeを利用してイメージのビルド
docker-compose build

# ECRに接続
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
if [ $? -ne 0 ]; then
    echo "Failed to login to ECR."
    exit 1
else
    echo "ECR login success"
fi

# DockerイメージをECRにプッシュ
docker tag $DOCKER_IMAGE_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$DOCKER_IMAGE_NAME:$IMAGE_TAG
if [ $? -ne 0 ]; then
    echo "Failed to tag the Docker image."
    exit 1
fi

docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$DOCKER_IMAGE_NAME:latest
if [ $? -ne 0 ]; then
    echo "Failed to push the Docker image to ECR."
    exit 1
else
    echo "ECR push success"
fi

# ECRにプッシュしたイメージをlambdaに更新
aws lambda update-function-code --function-name $LAMBDA_FUNC_NAME --image-uri $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$DOCKER_IMAGE_NAME:$IMAGE_TAG > /dev/null 2> /tmp/aws_lambda_error.log

if [ $? -eq 0 ]; then
    echo "lambda update success"
else
    # エラーメッセージを表示する
    cat /tmp/aws_lambda_error.log
    exit 1
fi

# 一時ファイルを削除
rm -f /tmp/aws_lambda_error.log
