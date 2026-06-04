# 项目 27：农产品溯源电商 App（Flutter）

> 本文件仅描述需求，不包含任何实现代码。UI 使用 Material 基础组件，不做美化。

## 一、项目简介
连接农户与消费者的农产品电商平台：产地直供、溯源码查询、季节性预售、拼团、冷链运费 Mock、农户店铺、质检报告展示、订阅箱。强调溯源链路可视化，Express Mock 维护批次与溯源节点。

## 二、技术栈

### 前端
- Flutter 3.22+ / Dart 3
- Riverpod + freezed
- go_router
- dio
- fl_chart（价格走势、产地销量 Mock）
- qr_flutter（展示溯源码，非扫描）

### 后端 Mock
- Express + SQLite
- 端口 `3014`

### Web 兼容约束
- **禁止**：mobile_scanner、camera、geolocator、google_maps
- **替代**：溯源=输入溯源码或点击商品内码；产地=文字+静态地图图片 URL

## 三、后端 Mock API 设计

| 模块 | 路径 | 说明 |
|------|------|------|
| 认证 | `/api/auth/*` | |
| 分类 | GET `/api/categories` | 果蔬、粮油等 |
| 商品 | GET `/api/products` | 农户、产地筛选 |
| 商品 | GET `/api/products/:id` | 含批次列表 |
| 溯源 | GET `/api/trace/:code` | 种植→采摘→质检→物流节点 |
| 农户 | GET `/api/farms/:id` | 店铺、故事 |
| 预售 | GET `/api/presales` | 定金+尾款 Mock |
| 拼团 | POST `/api/group-buys` | 开团/参团 |
| 拼团 | GET `/api/group-buys/:id` | 成团倒计时 |
| 购物车 | `/api/cart` | |
| 订单 | POST/GET `/api/orders` | 冷链费计算 |
| 订阅 | CRUD `/api/subscriptions` | 每周/每月箱 |
| 质检 | GET `/api/products/:id/reports` | PDF URL |
| 优惠券 | `/api/coupons` | |
| 搜索 | GET `/api/search` | |

**业务规则**
- 溯源码唯一绑定批次；无效码 404
- 拼团：满 3 人成团，24h 未成团退款
- 预售：定金 20%，尾款到货前 3 天提醒
- 冷链：特定分类 +固定运费 12 元 Mock

## 四、页面清单（≥22 页）

| 序号 | 页面 | 路由 | 说明 |
|------|------|------|------|
| 1 | 启动 | `/splash` | |
| 2 | 登录 | `/login` | |
| 3 | 首页 | `/home` | 产地故事、预售入口 |
| 4 | 分类 | `/categories` | |
| 5 | 商品列表 | `/products` | |
| 6 | 商品详情 | `/product/:id` | 批次、溯源入口 |
| 7 | 溯源查询 | `/trace` | 输入码 |
| 8 | 溯源结果 | `/trace/:code` | 时间轴节点 |
| 9 | 农户店铺 | `/farm/:id` | |
| 10 | 预售列表 | `/presales` | |
| 11 | 预售详情 | `/presale/:id` | 付定金 |
| 12 | 拼团列表 | `/group-buys` | |
| 13 | 拼团详情 | `/group-buy/:id` | |
| 14 | 购物车 | `/cart` | |
| 15 | 结算 | `/checkout` | |
| 16 | 订单列表 | `/orders` | |
| 17 | 订单详情 | `/order/:id` | |
| 18 | 订阅箱 | `/subscriptions` | |
| 19 | 创建订阅 | `/subscription/create` | |
| 20 | 质检报告 | `/product/:id/reports` | |
| 21 | 搜索 | `/search` | |
| 22 | 优惠券 | `/coupons` | |
| 23 | 个人中心 | `/profile` | |
| 24 | 设置 | `/settings` | |

**底部导航**：首页 | 分类 | 购物车 | 我的

## 五、核心功能需求
1. 溯源时间轴：竖向 Stepper + 节点详情
2. 拼团倒计时：前端 Timer + 后端 expireAt
3. 预售两阶段订单：定金单、尾款单关联 parentId
4. 订阅：下次配送日 cron Mock
5. Web 5184

## 六、编译与调试
```bash
cd backend && npm run dev    # :3014
flutter run -d chrome --web-port=5184 --dart-define=API_BASE=http://localhost:3014
```

## 七、交付物
- seed：≥60 商品、≥10 农户、每商品 2+ 溯源批次
- 测试：溯源码、拼团成团、预售尾款
- README

## 八、本次任务
**只列出需求和架构规划，不要写代码。**
请输出：
1. 商品-批次-溯源码关系模型
2. 拼团与预售状态机
3. 溯源链路 UI 组件设计
4. go_router 结构
5. SQLite 表
6. Web 端 qr_flutter 仅展示方案
