# zulonex.com

逐鹿未来官网，基于 Astro 构建。

## 本地运行

```bash
npm ci
npm run dev
```

## 构建

```bash
npm run check
npm run build
```

## 生产启动

```bash
PORT=4322 HOST=127.0.0.1 npm run start
```

## 部署包

当前可交付部署包位于：

```text
release/zulonex-website-2026-07-10-0835.zip
```

校验文件：

```text
release/zulonex-website-2026-07-10-0835.zip.sha256
```

该 zip 已包含最新 `dist` 构建产物，可直接交给研发部署。
