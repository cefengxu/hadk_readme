#!/bin/bash

# AWS S3 部署脚本
# 使用方法: ./deploy.sh [S3_BUCKET_NAME] [CLOUDFRONT_DISTRIBUTION_ID]

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查参数
if [ -z "$1" ]; then
    echo -e "${RED}错误: 请提供 S3 存储桶名称${NC}"
    echo "使用方法: ./deploy.sh <S3_BUCKET_NAME> [CLOUDFRONT_DISTRIBUTION_ID]"
    exit 1
fi

S3_BUCKET=$1
CLOUDFRONT_ID=$2

echo -e "${GREEN}开始构建 MkDocs 文档...${NC}"

# 检查是否安装了依赖
if ! command -v mkdocs &> /dev/null; then
    echo -e "${YELLOW}未检测到 mkdocs，正在安装依赖...${NC}"
    pip install -r requirements.txt
fi

# 构建文档
mkdocs build --clean

if [ $? -ne 0 ]; then
    echo -e "${RED}构建失败！${NC}"
    exit 1
fi

echo -e "${GREEN}构建成功！${NC}"
echo -e "${GREEN}开始上传到 S3...${NC}"

# 上传到 S3
aws s3 sync site/ s3://${S3_BUCKET}/ --delete --exact-timestamps

if [ $? -ne 0 ]; then
    echo -e "${RED}上传失败！${NC}"
    exit 1
fi

echo -e "${GREEN}上传成功！${NC}"

# 如果提供了 CloudFront 分发 ID，则清除缓存
if [ -n "$CLOUDFRONT_ID" ]; then
    echo -e "${GREEN}正在清除 CloudFront 缓存...${NC}"
    aws cloudfront create-invalidation \
        --distribution-id ${CLOUDFRONT_ID} \
        --paths "/*"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}缓存清除成功！${NC}"
    else
        echo -e "${YELLOW}警告: 缓存清除失败，但文件已上传${NC}"
    fi
fi

echo -e "${GREEN}部署完成！${NC}"

