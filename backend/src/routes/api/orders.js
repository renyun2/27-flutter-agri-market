const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');
const { calcColdChainFee } = require('../../utils/coldChain');
const { nowIso } = require('../../utils/date');

const router = express.Router();

function mapOrder(row) {
  return {
    ...row,
    items: JSON.parse(row.items_json || '[]'),
  };
}

router.use(authRequired);

router.get('/', (req, res) => {
  const rows = db
    .prepare('SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC LIMIT 100')
    .all(req.user.id);
  res.json({ items: rows.map(mapOrder) });
});

router.get('/:id', (req, res) => {
  const row = db
    .prepare('SELECT * FROM orders WHERE id = ? AND user_id = ?')
    .get(req.params.id, req.user.id);
  if (!row) return res.status(404).json({ error: '订单不存在', code: 404 });
  const children = db.prepare('SELECT * FROM orders WHERE parent_id = ?').all(row.id);
  res.json({ order: mapOrder(row), children: children.map(mapOrder) });
});

router.post('/', (req, res) => {
  const { couponCode, address } = req.body || {};
  const cart = db
    .prepare(
      `SELECT c.*, p.name, p.price, p.category_id
       FROM cart_items c JOIN products p ON p.id = c.product_id
       WHERE c.user_id = ?`
    )
    .all(req.user.id);
  if (!cart.length) return res.status(400).json({ error: '购物车为空', code: 400 });

  const items = cart.map((c) => ({
    product_id: c.product_id,
    name: c.name,
    qty: c.qty,
    price: c.price,
    batch_id: c.batch_id,
  }));
  const subtotal = items.reduce((s, i) => s + i.price * i.qty, 0);
  const productIds = items.map((i) => i.product_id);
  const coldChainFee = calcColdChainFee(productIds);
  let discount = 0;
  if (couponCode) {
    const coupon = db
      .prepare(
        `SELECT c.* FROM coupons c
         JOIN user_coupons uc ON uc.coupon_id = c.id
         WHERE uc.user_id = ? AND c.code = ? AND uc.used = 0`
      )
      .get(req.user.id, couponCode);
    if (coupon && subtotal >= coupon.min_amount) {
      discount = coupon.discount;
      db.prepare('UPDATE user_coupons SET used = 1 WHERE user_id = ? AND coupon_id = ?').run(
        req.user.id,
        coupon.id
      );
    }
  }
  const total = Math.max(0, subtotal + coldChainFee - discount);
  const orderId = uuid();
  db.prepare(
    `INSERT INTO orders (id, user_id, order_type, status, items_json, subtotal, cold_chain_fee, discount, total_amount)
     VALUES (?,?,?,?,?,?,?,?,?)`
  ).run(
    orderId,
    req.user.id,
    'normal',
    'pending_payment',
    JSON.stringify(items),
    subtotal,
    coldChainFee,
    discount,
    total
  );
  db.prepare('DELETE FROM cart_items WHERE user_id = ?').run(req.user.id);
  const order = mapOrder(db.prepare('SELECT * FROM orders WHERE id = ?').get(orderId));
  res.status(201).json({ order, address: address || '默认地址 Mock' });
});

router.post('/:id/pay', (req, res) => {
  const order = db
    .prepare('SELECT * FROM orders WHERE id = ? AND user_id = ?')
    .get(req.params.id, req.user.id);
  if (!order) return res.status(404).json({ error: '订单不存在', code: 404 });
  if (order.status !== 'pending_payment') {
    return res.status(400).json({ error: '订单状态不可支付', code: 400 });
  }
  db.prepare(`UPDATE orders SET status = 'paid', paid_at = ? WHERE id = ?`).run(
    nowIso(),
    order.id
  );
  if (order.order_type === 'presale_deposit') {
    const balanceId = uuid();
    db.prepare(
      `INSERT INTO orders (id, user_id, order_type, status, parent_id, presale_id, items_json,
        subtotal, total_amount, balance_amount, balance_due_at)
       VALUES (?,?,?,?,?,?,?,?,?,?,?)`
    ).run(
      balanceId,
      req.user.id,
      'presale_balance',
      'pending_payment',
      order.id,
      order.presale_id,
      order.items_json,
      order.subtotal,
      order.balance_amount,
      order.balance_amount,
      order.balance_due_at
    );
  }
  res.json({ order: mapOrder(db.prepare('SELECT * FROM orders WHERE id = ?').get(order.id)) });
});

router.post('/:id/pay-balance', (req, res) => {
  const order = db
    .prepare('SELECT * FROM orders WHERE id = ? AND user_id = ? AND order_type = ?')
    .get(req.params.id, req.user.id, 'presale_balance');
  if (!order) return res.status(404).json({ error: '尾款订单不存在', code: 404 });
  db.prepare(`UPDATE orders SET status = 'paid', paid_at = ? WHERE id = ?`).run(nowIso(), order.id);
  res.json({ order: mapOrder(db.prepare('SELECT * FROM orders WHERE id = ?').get(order.id)) });
});

module.exports = router;
