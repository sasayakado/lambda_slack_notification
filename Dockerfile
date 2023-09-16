FROM public.ecr.aws/lambda/python:3.8

# ワーキングディレクトリを設定
WORKDIR /var/task

# PYTHONPATH の設定
ENV PYTHONPATH="/var/task/app"

# 依存関係のコピー
COPY requirements.txt .

# yumを更新し、必要なパッケージをインストール
RUN yum update -y && \
    yum install -y tar unzip gzip

RUN mkdir -p /opt/bin

# 依存関係のインストール
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# appディレクトリを/var/task/app/へコピー
COPY app/ /var/task/app/

CMD ["lambda_function.lambda_handler"]
