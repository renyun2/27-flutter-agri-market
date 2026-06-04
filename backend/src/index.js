const express = require('express');
const cors = require('cors');
const { seed } = require('./seed');
const { expireStaleGroupBuys } = require('./utils/groupBuy');
const { advanceSubscriptionDates } = require('./utils/subscriptions');

const authRoutes = require('./routes/api/auth');
const categoriesRoutes = require('./routes/api/categories');
const productsRoutes = require('./routes/api/products');
const traceRoutes = require('./routes/api/trace');
const farmsRoutes = require('./routes/api/farms');
const presalesRoutes = require('./routes/api/presales');
const groupBuysRoutes = require('./routes/api/groupBuys');
const cartRoutes = require('./routes/api/cart');
const ordersRoutes = require('./routes/api/orders');
const subscriptionsRoutes = require('./routes/api/subscriptions');
const couponsRoutes = require('./routes/api/coupons');
const searchRoutes = require('./routes/api/search');

seed();

const app = express();
const PORT = process.env.PORT || 3014;

app.use(cors({ origin: true }));
app.use(express.json());

setInterval(() => {
  expireStaleGroupBuys();
  advanceSubscriptionDates();
}, 60 * 1000);

app.get('/health', (_req, res) => res.json({ ok: true, service: 'agri-market' }));

app.use('/api/auth', authRoutes);
app.use('/api/categories', categoriesRoutes);
app.use('/api/products', productsRoutes);
app.use('/api/trace', traceRoutes);
app.use('/api/farms', farmsRoutes);
app.use('/api/presales', presalesRoutes);
app.use('/api/group-buys', groupBuysRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/orders', ordersRoutes);
app.use('/api/subscriptions', subscriptionsRoutes);
app.use('/api/coupons', couponsRoutes);
app.use('/api/search', searchRoutes);

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Agri market backend running at http://localhost:${PORT}`);
    console.log(`API base: http://localhost:${PORT}/api`);
  });
}

module.exports = app;
