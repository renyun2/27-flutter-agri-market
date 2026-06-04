# 农产品溯源电商 App

连接农户与消费者的农产品电商平台：产地直供、溯源码查询、季节性预售、拼团、冷链运费 Mock、农户店铺、质检报告、订阅箱。Express Mock 后端 + Flutter Web 调试。

## 技术栈

| 层 | 技术 |
|---|---|
| 前端 | Flutter 3.22+、Riverpod、go_router、dio、fl_chart、qr_flutter（仅展示溯源码） |
| 后端 Mock | Express + better-sqlite3，端口 **3014** |

## 测试账号

| 手机号 | 密码 |
|--------|------|
| 13800138000 | 123456 |

## 快速开始

### 1. 启动 Mock 后端

```bash
cd backend
npm install
npm run dev
```

服务地址：`http://localhost:3014`

### 2. Web 调试 Flutter

```bash
cd mobile
flutter pub get
flutter run -d chrome --web-port=5184 --dart-define=API_BASE=http://localhost:3014
```

## 路由（24 页）

| 路由 | 页面 |
|------|------|
| `/splash` | 启动 |
| `/login` | 登录 |
| `/home` | 首页（Tab） |
| `/categories` | 分类（Tab） |
| `/products` | 商品列表 |
| `/product/:id` | 商品详情 |
| `/trace` | 溯源查询 |
| `/trace/:code` | 溯源结果时间轴 |
| `/farm/:id` | 农户店铺 |
| `/presales` | 预售列表 |
| `/presale/:id` | 预售付定金 |
| `/group-buys` | 拼团列表 |
| `/group-buy/:id` | 拼团详情+倒计时 |
| `/cart` | 购物车（Tab） |
| `/checkout` | 结算 |
| `/orders` | 订单列表 |
| `/order/:id` | 订单详情 |
| `/subscriptions` | 订阅箱 |
| `/subscription/create` | 创建订阅 |
| `/product/:id/reports` | 质检报告 |
| `/search` | 搜索 |
| `/coupons` | 优惠券 |
| `/profile` | 个人中心（Tab） |
| `/settings` | 设置 |

**底部导航**：首页 | 分类 | 购物车 | 我的

## 业务规则（Mock）

- **溯源码**：唯一绑定批次；无效码返回 404
- **拼团**：满 3 人成团；24h 未成团失败退款 Mock
- **预售**：定金 20%；支付定金后生成尾款单（`parent_id` 关联）
- **冷链**：冷冻海鲜等分类结算时加收 12 元

## 测试

```bash
cd backend && npm test
cd mobile && flutter test
```

覆盖：溯源码查询、拼团成团、预售尾款。

## Seed 数据

- 62 款商品、12 个农户、每商品 2 个溯源批次（如 `AGRI-001-1`）
- 8 条预售、质检报告、优惠券
- 拼团样例（2/3 人，可参团凑满）

## Web 约束

未使用 mobile_scanner、camera、geolocator、google_maps；溯源通过输入码或商品内二维码展示（`qr_flutter`）。
