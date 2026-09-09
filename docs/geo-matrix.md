# GEO 多城市矩阵官网

## 当前实现

官网通过 `src/lib/geoContext.ts` 统一解析 `GeoContext`：

- 默认城市：`全国`
- 城市预览：`?city=杭州`
- 部署默认城市：`PUBLIC_GEO_CITY=杭州`
- SEO Title：`杭州星鹿爱学/逐鹿未来官网 - 本地智能教育服务`
- 预约表单：自动提交隐藏字段 `source_city=杭州`

## 本地预览

```text
http://localhost:4321/?city=杭州
http://localhost:4321/contact/?city=杭州
http://localhost:4321/cooperation/?city=杭州
```

## 生产部署

GEO SEO 需要服务端根据请求生成页面，因此 Astro 使用 `output: "server"`。部署时继续使用项目现有的 Node/Docker 启动方式，并按城市入口或反向代理规则传入 `?city=`，后续可再将城市参数升级为独立路径，例如 `/hangzhou/`。

## 表单字段

`source_city` 是来源城市，用于区分访客进入的 GEO 页面；`city` 仍然保留为用户在表单中填写的实际所在城市。
