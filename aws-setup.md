# AWS 部署指南

本指南将帮助您在 AWS 上部署 MkDocs 文档站点。

## 方案概述

我们使用以下 AWS 服务：
- **S3**: 存储静态网站文件
- **CloudFront** (可选): CDN 加速和 HTTPS
- **Route 53** (可选): 自定义域名

## 方案一：S3 静态网站托管（简单方案）

### 1. 创建 S3 存储桶

```bash
# 创建存储桶（请替换为您的唯一存储桶名称）
aws s3 mb s3://your-docs-bucket-name --region us-east-1
```

### 2. 配置 S3 存储桶为静态网站托管

```bash
# 启用静态网站托管
aws s3 website s3://your-docs-bucket-name \
    --index-document index.html \
    --error-document 404.html
```

或者通过 AWS 控制台：
1. 进入 S3 控制台
2. 选择您的存储桶
3. 进入 "Properties" 标签
4. 滚动到 "Static website hosting"
5. 点击 "Edit"
6. 启用静态网站托管
7. 设置索引文档为 `index.html`
8. 保存更改

### 3. 配置存储桶策略

创建存储桶策略文件 `bucket-policy.json`：

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::your-docs-bucket-name/*"
    }
  ]
}
```

应用策略：

```bash
aws s3api put-bucket-policy \
    --bucket your-docs-bucket-name \
    --policy file://bucket-policy.json
```

### 4. 部署文档

```bash
# 构建文档
mkdocs build

# 上传到 S3
aws s3 sync site/ s3://your-docs-bucket-name/ --delete
```

### 5. 访问网站

访问 URL 格式：
```
http://your-docs-bucket-name.s3-website-us-east-1.amazonaws.com
```

## 方案二：S3 + CloudFront（推荐方案）

### 1. 完成方案一的前 3 步

### 2. 创建 CloudFront 分发

#### 通过 AWS CLI：

```bash
aws cloudfront create-distribution \
    --origin-domain-name your-docs-bucket-name.s3.amazonaws.com \
    --default-root-object index.html
```

#### 通过 AWS 控制台：

1. 进入 CloudFront 控制台
2. 点击 "Create Distribution"
3. 配置：
   - **Origin Domain**: 选择您的 S3 存储桶（选择存储桶，不是网站端点）
   - **Origin Path**: 留空
   - **Viewer Protocol Policy**: Redirect HTTP to HTTPS
   - **Allowed HTTP Methods**: GET, HEAD
   - **Default Root Object**: index.html
4. 创建分发
5. 等待分发部署完成（约 15-20 分钟）

### 3. 更新 S3 存储桶策略

如果使用 CloudFront，可以限制 S3 存储桶只允许 CloudFront 访问：

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFrontAccess",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudfront.amazonaws.com"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::your-docs-bucket-name/*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "arn:aws:cloudfront::ACCOUNT_ID:distribution/DISTRIBUTION_ID"
        }
      }
    }
  ]
}
```

### 4. 部署文档

使用提供的部署脚本：

```bash
chmod +x deploy.sh
./deploy.sh your-docs-bucket-name your-cloudfront-distribution-id
```

### 5. 访问网站

使用 CloudFront 分配的域名：
```
https://d1234567890abc.cloudfront.net
```

## 方案三：使用 GitHub Actions 自动部署

### 1. 配置 GitHub Secrets

在 GitHub 仓库设置中添加以下 Secrets：
- `AWS_ACCESS_KEY_ID`: AWS 访问密钥 ID
- `AWS_SECRET_ACCESS_KEY`: AWS 密钥
- `S3_BUCKET_NAME`: S3 存储桶名称
- `CLOUDFRONT_DISTRIBUTION_ID`: CloudFront 分发 ID（可选）

### 2. 创建 IAM 用户和策略

创建 IAM 用户并附加以下策略：

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::your-docs-bucket-name",
        "arn:aws:s3:::your-docs-bucket-name/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateInvalidation"
      ],
      "Resource": "*"
    }
  ]
}
```

### 3. 推送代码

当您推送代码到 main/master 分支时，GitHub Actions 会自动构建并部署文档。

## 本地测试

在部署前，您可以在本地测试：

```bash
# 安装依赖
pip install -r requirements.txt

# 启动本地服务器
mkdocs serve

# 访问 http://127.0.0.1:8000
```

## 常见问题

### 1. 403 Forbidden 错误

- 检查 S3 存储桶策略是否正确配置
- 如果使用 CloudFront，检查 OAI/OAC 配置

### 2. 404 错误

- 确保 `index.html` 存在于根目录
- 检查 CloudFront 的默认根对象设置

### 3. 样式丢失

- 检查 CloudFront 的缓存设置
- 清除 CloudFront 缓存

## 成本估算

- **S3**: 存储约 $0.023/GB/月，请求约 $0.0004/1000 次
- **CloudFront**: 数据传输约 $0.085/GB（前 10TB），请求约 $0.0075/10000 次
- **Route 53**: 托管区域 $0.50/月，查询约 $0.40/百万次

对于小型文档站点，预计每月成本 < $1。

