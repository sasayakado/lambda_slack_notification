#!/bin/bash
set -e

# ./.envファイルを読み込んで変数として参照できるようにする
source ./.env

# 既存のコンテナが存在するか確認
EXISTING_CONTAINER=$(docker ps -a -qf "name=$DOCKER_CONTAINER_NAME")

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
    docker image rm $EXISTING_IMAGE
fi

echo "Done."
