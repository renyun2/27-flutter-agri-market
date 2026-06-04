const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');
const { addDays, nowIso } = require('../../utils/date');

const router = express.Router();

router.get('/', (_req, res) => {
  const items = db
    .prepare(
      `SELECT ps.*, p.name AS product_name, p.image_url, p.origin
       FROM presales ps
       JOIN products p ON p.id = ps.product_id
       WHERE ps.status = 'open'
       ORDER BY ps.harvest_date`
    )
    .all();
  res.json({ items });
});

router.get('/:id', (req, res) => {
  const row = db
    .prepare(
      `SELECT ps.*, p.name AS product_name, p.image_url, p.origin, p.price AS list_price
       FROM presales ps
       JOIN products p ON p.id = ps.product_id
       WHERE ps.id = ?`
    )
    .get(req.params.id);
  if (!row) return res.status(404).json({ error: '预售不存在', code: 404 });
  res.json({ presale: row });
});

router.post('/:id/deposit', authRequired, (req, res) => {
  const presale = db.prepare('SELECT * FROM presales WHERE id = ?').get(req.params.id);
  if (!presale || presale.status !== 'open') {
    return res.status(404).json({ error: '预售不可用', code: 404 });
  }
  const deposit = Math.round(presale.full_price * presale.deposit_rate * 100) / 100;
  const balance = Math.round((presale.full_price - deposit) * 100) / 100;
  const orderId = uuid();
  const items = [
    {
      product_id: presale.product_id,
      name: presale.title,
      qty: 1,
      price: presale.full_price,
    },
  ];
  db.prepare(
    `INSERT INTO orders (id, user_id, order_type, status, presale_id, items_json,
      subtotal, total_amount, deposit_amount, balance_amount, balance_due_at)
     VALUES (?,?,?,?,?,?,?,?,?,?,?)`
  ).run(
    orderId,
    req.user.id,
    'presale_deposit',
    'pending_payment',
    presale.id,
    JSON.stringify(items),
    presale.full_price,
    deposit,
    deposit,
    balance,
    presale.balance_due_at
  );
  const order = db.prepare('SELECT * FROM orders WHERE id = ?').get(orderId);
  res.status(201).json({ order });
});

router.post('/:id/pay-deposit', authRequired, (req, res) => {
  const order = db
    .prepare(
      `SELECT * FROM orders WHERE presale_id = ? AND user_id = ? AND order_type = 'presale_deposit'
       ORDER BY created_at DESC LIMIT 1`
    )
    .get(req.params.id, req.user.id);
  if (!order) return res.status(404).json({ error: '无定金订单', code: 404 });
  db.prepare(`UPDATE orders SET status = 'paid', paid_at = ? WHERE id = ?`).run(nowIso(), order.id);
  res.json({ order: db.prepare('SELECT * FROM orders WHERE id = ?').get(order.id) });
});

module.exports = router;
