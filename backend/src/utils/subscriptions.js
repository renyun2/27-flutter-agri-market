const db = require('../db');
const { addDays, todayStr } = require('./date');

function advanceSubscriptionDates() {
  const subs = db
    .prepare(`SELECT id, frequency, next_delivery_at FROM subscriptions WHERE status = 'active'`)
    .all();
  const today = todayStr();
  for (const s of subs) {
    if (s.next_delivery_at <= today) {
      const days = s.frequency === 'weekly' ? 7 : 30;
      const next = addDays(s.next_delivery_at, days);
      db.prepare('UPDATE subscriptions SET next_delivery_at = ? WHERE id = ?').run(next, s.id);
    }
  }
}

module.exports = { advanceSubscriptionDates };
