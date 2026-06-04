const express = require('express');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, (req, res) => {
  const available = db
    .prepare(
      `SELECT c.* FROM coupons c
       WHERE datetime(c.expires_at) > datetime('now')
       AND c.id NOT IN (SELECT coupon_id FROM user_coupons WHERE user_id = ?)`
    )
    .all(req.user.id);
  const mine = db
    .prepare(
      `SELECT c.*, uc.used, uc.claimed_at
       FROM user_coupons uc
       JOIN coupons c ON c.id = uc.coupon_id
       WHERE uc.user_id = ?`
    )
    .all(req.user.id);
  res.json({ available, claimed: mine });
});

router.post('/claim', authRequired, (req, res) => {
  const { code } = req.body || {};
  const coupon = db.prepare('SELECT * FROM coupons WHERE code = ?').get(code);
  if (!coupon) return res.status(404).json({ error: '优惠券不存在', code: 404 });
  try {
    db.prepare('INSERT INTO user_coupons (user_id, coupon_id) VALUES (?,?)').run(
      req.user.id,
      coupon.id
    );
  } catch {
    return res.status(409).json({ error: '已领取', code: 409 });
  }
  res.json({ coupon });
});

module.exports = router;
