# 逐鹿未来官网部署说明

## 交付状态

- 2026-06-30 已通过类型检查、生产构建和本地生产服务验证。
- 交付包同时包含源码、锁定依赖清单、已构建的 `dist` 和 Docker 配置。
- 正式上线前仍需填写联系电话、备案号，并配置企业微信或飞书通知地址。
- 预约接口是公开接口，建议在阿里云 WAF、网关或 Nginx 中为 `/api/leads` 配置访问频率限制。

## 运行环境

- Node.js 22.12 或更高版本。
- npm 10 或兼容版本。
- 生产服务默认监听 `0.0.0.0:8080`。
- 官网包含 `/api/leads` 动态接口，不能只把 HTML 上传到纯静态空间。

## 环境变量

`PUBLIC_BUSINESS_LOGIN_URL` 在构建时写入前端，用于商家登录入口。

`WECHAT_WEBHOOK_URL`、`FEISHU_WEBHOOK_URL` 和 `LEADS_FILE` 在运行时使用。

```bash
PUBLIC_BUSINESS_LOGIN_URL=https://boss.zulonex.com
WECHAT_WEBHOOK_URL=
FEISHU_WEBHOOK_URL=
LEADS_FILE=/data/zulonex/leads.jsonl
HOST=0.0.0.0
PORT=8080
```

正式部署前请确认 `PUBLIC_BUSINESS_LOGIN_URL`，再执行生产构建。

## 常规部署

```bash
npm ci
npm test
HOST=0.0.0.0 PORT=8080 npm start
```

如果直接使用交付包内已经构建好的 `dist`：

```bash
npm ci --omit=dev
HOST=0.0.0.0 PORT=8080 npm start
```

## Docker 部署

```bash
docker build \
  --build-arg PUBLIC_BUSINESS_LOGIN_URL=https://boss.zulonex.com \
  -t zulonex-website:latest .

docker run -d \
  --name zulonex-website \
  --restart unless-stopped \
  -p 8080:8080 \
  -e WECHAT_WEBHOOK_URL= \
  -e FEISHU_WEBHOOK_URL= \
  -v /data/zulonex:/app/data \
  zulonex-website:latest
```

## Nginx 反向代理示例

```nginx
server {
    listen 80;
    server_name zulonex.com www.zulonex.com;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

生产环境应由云平台或 Nginx 配置 HTTPS，并将 HTTP 重定向至 HTTPS。

## 可写目录

表单线索默认写入 `data/leads.jsonl`。生产环境必须：

1. 通过 `LEADS_FILE` 指定持久化路径。
2. 确保运行用户对目录有写权限。
3. 配置备份、访问限制和数据保留周期。
4. 不要将线索文件放入公开静态目录。

## 部署后检查

```bash
curl -I https://zulonex.com/
curl -I https://zulonex.com/product/
curl -I https://zulonex.com/solutions/
curl -I https://zulonex.com/login/
curl -I https://zulonex.com/privacy/
curl -I https://zulonex.com/sitemap.xml
```

同时检查：

- 商家登录跳转地址和手机端参数。
- 预约表单成功与失败提示。
- 企业微信或飞书通知。
- `data` 目录持久化。
- HTTPS、备案信息、隐私政策和移动端布局。
