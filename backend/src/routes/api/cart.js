const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

function listCart(userId) {
  return db
    .prepare(
      `SELECT c.id, c.product_id, c.batch_id, c.qty,
              p.name, p.price, p.unit, p.image_url, p.origin, p.category_id,
              b.trace_code, cat.cold_chain
       FROM cart_items c
       JOIN products p ON p.id = c.product_id
       LEFT JOIN batches b ON b.id = c.batch_id
       JOIN categories cat ON cat.id = p.category_id
       WHERE c.user_id = ?`
    )
    .all(userId);
}

router.use(authRequired);

router.get('/', (req, res) => {
  const items = listCart(req.user.id);
  const subtotal = items.reduce((s, i) => s + i.price * i.qty, 0);
  res.json({ items, subtotal });
});

router.post('/', (req, res) => {
  const { productId, batchId, qty = 1 } = req.body || {};
  if (!productId) return res.status(400).json({ error: '缺少商品', code: 400 });
  const product = db.prepare('SELECT id FROM products WHERE id = ?').get(productId);
  if (!product) return res.status(404).json({ error: '商品不存在', code: 404 });

  const existing = db
    .prepare(
      'SELECT id FROM cart_items WHERE user_id = ? AND product_id = ? AND (batch_id IS ? OR batch_id = ?)'
    )
    .get(req.user.id, productId, batchId || null, batchId || null);
  if (existing) {
    db.prepare('UPDATE cart_items SET qty = qty + ? WHERE id = ?').run(qty, existing.id);
  } else {
    db.prepare(
      'INSERT INTO cart_items (id, user_id, product_id, batch_id, qty) VALUES (?,?,?,?,?)'
    ).run(uuid(), req.user.id, productId, batchId || null, qty);
  }
  res.json({ items: listCart(req.user.id) });
});

router.patch('/:id', (req, res) => {
  const { qty } = req.body || {};
  if (!qty || qty < 1) return res.status(400).json({ error: '数量无效', code: 400 });
  const row = db
    .prepare('SELECT id FROM cart_items WHERE id = ? AND user_id = ?')
    .get(req.params.id, req.user.id);
  if (!row) return res.status(404).json({ error: '购物车项不存在', code: 404 });
  db.prepare('UPDATE cart_items SET qty = ? WHERE id = ?').run(qty, req.params.id);
  res.json({ items: listCart(req.user.id) });
});

router.delete('/:id', (req, res) => {
  db.prepare('DELETE FROM cart_items WHERE id = ? AND user_id = ?').run(
    req.params.id,
    req.user.id
  );
  res.json({ items: listCart(req.user.id) });
});

module.exports = router;
