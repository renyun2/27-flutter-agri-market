const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');
const { addDays, todayStr } = require('../../utils/date');
const { advanceSubscriptionDates } = require('../../utils/subscriptions');

const router = express.Router();

router.use(authRequired);

router.get('/', (req, res) => {
  advanceSubscriptionDates();
  const items = db
    .prepare('SELECT * FROM subscriptions WHERE user_id = ? ORDER BY created_at DESC')
    .all(req.user.id);
  res.json({
    items: items.map((s) => ({
      ...s,
      items: JSON.parse(s.items_json || '[]'),
    })),
  });
});

router.post('/', (req, res) => {
  const { name, frequency, items } = req.body || {};
  if (!name || !frequency || !items?.length) {
    return res.status(400).json({ error: '请填写订阅信息', code: 400 });
  }
  const days = frequency === 'weekly' ? 7 : 30;
  const id = uuid();
  const next = addDays(todayStr(), days);
  db.prepare(
    `INSERT INTO subscriptions (id, user_id, name, frequency, items_json, next_delivery_at)
     VALUES (?,?,?,?,?,?)`
  ).run(id, req.user.id, name, frequency, JSON.stringify(items), next);
  const row = db.prepare('SELECT * FROM subscriptions WHERE id = ?').get(id);
  res.status(201).json({ subscription: { ...row, items: JSON.parse(row.items_json) } });
});

router.patch('/:id', (req, res) => {
  const row = db
    .prepare('SELECT * FROM subscriptions WHERE id = ? AND user_id = ?')
    .get(req.params.id, req.user.id);
  if (!row) return res.status(404).json({ error: '订阅不存在', code: 404 });
  const { status, name } = req.body || {};
  if (status) db.prepare('UPDATE subscriptions SET status = ? WHERE id = ?').run(status, row.id);
  if (name) db.prepare('UPDATE subscriptions SET name = ? WHERE id = ?').run(name, row.id);
  const updated = db.prepare('SELECT * FROM subscriptions WHERE id = ?').get(row.id);
  res.json({ subscription: { ...updated, items: JSON.parse(updated.items_json) } });
});

router.delete('/:id', (req, res) => {
  db.prepare('DELETE FROM subscriptions WHERE id = ? AND user_id = ?').run(
    req.params.id,
    req.user.id
  );
  res.json({ ok: true });
});

module.exports = router;
