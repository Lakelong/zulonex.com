# 逐鹿未来官网与 ZULONEX 业务系统登录契约

## 目标

官网只提供统一商家入口和品牌化登录引导。账户、组织、角色、合作状态、菜单权限、数据范围与资源权限均由 ZULONEX 业务系统判定和执行。

## 应用边界

- `www.zulonex.com`：公开官网、预约演示、统一登录入口。
- ZULONEX 商家工作台：经销商、交付中心等合作伙伴的业务与资料入口。
- ZULONEX 总部后台：总部运营与系统管理。
- 官网不得保存密码、角色清单或权限规则。
- 前端隐藏按钮不能代替服务端权限校验。

## 登录流程

1. 用户从官网点击“商家登录”。
2. 官网向统一登录地址附加 `source=zulonex.com`、`terminal=desktop|mobile` 和 `target=auto`。
3. 业务系统完成认证并读取账户所属组织、角色、合作状态和可用应用。
4. 单一工作空间直接进入；多个工作空间在认证后选择。
5. 业务系统按照角色、状态和终端返回最终落地页。
6. 无权限、冻结、待审核或合作到期账户由业务系统返回明确状态，官网不自行推断。

## 推荐会话接口

`GET /api/auth/session`

```json
{
  "authenticated": true,
  "user": {
    "id": "user-id",
    "displayName": "用户名称"
  },
  "organization": {
    "id": "org-id",
    "name": "机构名称",
    "type": "dealer"
  },
  "status": "active",
  "workspaces": [
    {
      "key": "merchant",
      "label": "商家工作台",
      "role": "dealer_owner",
      "landingUrl": "/merchant"
    }
  ]
}
```

## 状态约定

- `pending`：待审核。
- `trial`：试运行。
- `active`：正常使用。
- `suspended`：暂停使用。
- `expired`：合作到期。
- `terminated`：合作终止。

状态名称可以对接现有字典，但必须由服务端返回，官网不维护映射权限。

## 终端路由

- `terminal=desktop`：进入桌面工作台。
- `terminal=mobile`：进入移动工作台或响应式商家端。
- 终端只影响界面与默认落地页，不改变权限。
- 移动端应保留切换桌面版入口。

## 安全要求

- 统一认证采用 HTTPS 和安全 Cookie 或标准 OAuth/OIDC 流程。
- 登录回跳地址使用白名单，禁止任意跳转。
- 资源查看、下载和分享必须由服务端二次校验。
- 文件使用私有对象存储和短时签名地址。
- 登录、查看、下载、分享和权限变更需要审计记录。

## 官网配置

官网通过 `PUBLIC_BUSINESS_LOGIN_URL` 配置统一登录地址。未配置时使用当前已核验的业务系统域名 `https://boss.zulonex.com`，正式上线前应替换为统一认证入口。
