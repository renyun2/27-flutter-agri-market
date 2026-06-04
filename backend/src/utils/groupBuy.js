const db = require('../db');
const { nowIso } = require('./date');

const TARGET = 3;

function expireStaleGroupBuys() {
  const stale = db
    .prepare(
      `SELECT id FROM group_buys
       WHERE status = 'open' AND expire_at < ?`
    )
    .all(nowIso());
  for (const g of stale) {
    db.prepare(`UPDATE group_buys SET status = 'failed' WHERE id = ?`).run(g.id);
    db.prepare(
      `UPDATE orders SET status = 'refunded'
       WHERE group_buy_id = ? AND status IN ('pending_payment','paid')`
    ).run(g.id);
  }
}

function tryCompleteGroupBuy(groupId) {
  const g = db.prepare('SELECT * FROM group_buys WHERE id = ?').get(groupId);
  if (!g || g.status !== 'open') return g;
  if (g.member_count >= g.target_count) {
    db.prepare(`UPDATE group_buys SET status = 'completed' WHERE id = ?`).run(groupId);
    return db.prepare('SELECT * FROM group_buys WHERE id = ?').get(groupId);
  }
  return g;
}

module.exports = { TARGET, expireStaleGroupBuys, tryCompleteGroupBuy };
