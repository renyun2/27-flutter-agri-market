const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');
const { addHours, nowIso } = require('../../utils/date');
const { TARGET, expireStaleGroupBuys, tryCompleteGroupBuy } = require('../../utils/groupBuy');

const router = express.Router();

function mapGroup(row) {
  return {
    id: row.id,
    product_id: row.product_id,
    product_name: row.product_name,
    leader_user_id: row.leader_user_id,
    status: row.status,
    target_count: row.target_count,
    member_count: row.member_count,
    group_price: row.group_price,
    expire_at: row.expire_at,
    created_at: row.created_at,
  };
}

router.get('/', (_req, res) => {
  expireStaleGroupBuys();
  const items = db
    .prepare(
      `SELECT g.*, p.name AS product_name
       FROM group_buys g
       JOIN products p ON p.id = g.product_id
       WHERE g.status IN ('open','completed')
       ORDER BY g.created_at DESC
       LIMIT 50`
    )
    .all();
  res.json({ items: items.map(mapGroup) });
});

router.get('/:id', (req, res) => {
  expireStaleGroupBuys();
  const row = db
    .prepare(
      `SELECT g.*, p.name AS product_name
       FROM group_buys g
       JOIN products p ON p.id = g.product_id
       WHERE g.id = ?`
    )
    .get(req.params.id);
  if (!row) return res.status(404).json({ error: '拼团不存在', code: 404 });
  const members = db
    .prepare(
      `SELECT m.user_id, m.joined_at, u.name AS user_name
       FROM group_buy_members m
       JOIN users u ON u.id = m.user_id
       WHERE m.group_buy_id = ?`
    )
    .all(req.params.id);
  res.json({ group_buy: mapGroup(row), members });
});

router.post('/', authRequired, (req, res) => {
  expireStaleGroupBuys();
  const { productId, groupBuyId, action } = req.body || {};
  if (action === 'join') {
    if (!groupBuyId) return res.status(400).json({ error: '缺少拼团 ID', code: 400 });
    const g = db.prepare('SELECT * FROM group_buys WHERE id = ?').get(groupBuyId);
    if (!g || g.status !== 'open') {
      return res.status(400).json({ error: '拼团已结束或不存在', code: 400 });
    }
    if (new Date(g.expire_at) < new Date()) {
      db.prepare(`UPDATE group_buys SET status = 'failed' WHERE id = ?`).run(groupBuyId);
      return res.status(400).json({ error: '拼团已过期', code: 400 });
    }
    const exists = db
      .prepare('SELECT 1 FROM group_buy_members WHERE group_buy_id = ? AND user_id = ?')
      .get(groupBuyId, req.user.id);
    if (exists) return res.status(409).json({ error: '已参团', code: 409 });

    db.prepare('INSERT INTO group_buy_members (group_buy_id, user_id) VALUES (?,?)').run(
      groupBuyId,
      req.user.id
    );
    db.prepare('UPDATE group_buys SET member_count = member_count + 1 WHERE id = ?').run(groupBuyId);
    const updated = tryCompleteGroupBuy(groupBuyId);
    return res.json({ group_buy: mapGroup({ ...updated, product_name: g.product_name || '' }) });
  }

  if (!productId) return res.status(400).json({ error: '缺少商品', code: 400 });
  const product = db.prepare('SELECT id, name, price FROM products WHERE id = ?').get(productId);
  if (!product) return res.status(404).json({ error: '商品不存在', code: 404 });

  const id = uuid();
  const expireAt = addHours(nowIso(), 24);
  const groupPrice = Math.round(product.price * 0.85 * 100) / 100;
  db.prepare(
    `INSERT INTO group_buys (id, product_id, leader_user_id, member_count, group_price, expire_at)
     VALUES (?,?,?,?,?,?)`
  ).run(id, productId, req.user.id, 1, groupPrice, expireAt);
  db.prepare('INSERT INTO group_buy_members (group_buy_id, user_id) VALUES (?,?)').run(
    id,
    req.user.id
  );
  const row = db
    .prepare(
      `SELECT g.*, p.name AS product_name FROM group_buys g
       JOIN products p ON p.id = g.product_id WHERE g.id = ?`
    )
    .get(id);
  res.status(201).json({ group_buy: mapGroup(row) });
});

module.exports = router;
