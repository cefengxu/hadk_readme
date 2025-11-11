# HADK 文档

基于 MkDocs 的 HADK 框架开发文档。

## 本地开发

### 安装依赖

```bash
pip install -r requirements.txt
```

### 启动本地服务器

```bash
mkdocs serve
```

访问 http://127.0.0.1:8000 查看文档。

### 构建静态站点

```bash
mkdocs build
```

构建后的文件在 `site/` 目录中。

## AWS 部署

### 快速部署

1. 配置 AWS 凭证：
```bash
aws configure
```

2. 使用部署脚本：
```bash
chmod +x deploy.sh
./deploy.sh your-s3-bucket-name [cloudfront-distribution-id]
```

### 详细部署指南

请参考 [aws-setup.md](aws-setup.md) 获取详细的 AWS 部署说明。

## 项目结构

```
.
├── docs/              # 文档源文件
├── site/              # 构建后的静态文件（自动生成）
├── mkdocs.yml         # MkDocs 配置文件
├── requirements.txt   # Python 依赖
├── deploy.sh          # 部署脚本
└── aws-setup.md       # AWS 部署指南
```

## 文档编辑

所有文档文件位于 `docs/` 目录中，使用 Markdown 格式编写。

修改文档后：
- 本地开发：`mkdocs serve` 会自动重新加载
- 部署：运行 `./deploy.sh` 或推送到 GitHub（如果配置了 CI/CD）

