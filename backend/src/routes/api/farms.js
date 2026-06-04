const express = require('express');
const db = require('../../db');

const router = express.Router();

router.get('/:id', (req, res) => {
  const farm = db.prepare('SELECT * FROM farms WHERE id = ?').get(req.params.id);
  if (!farm) return res.status(404).json({ error: '农户不存在', code: 404 });
  const products = db
    .prepare(
      `SELECT p.id, p.name, p.price, p.unit, p.origin, p.image_url
       FROM products p WHERE p.farm_id = ? LIMIT 30`
    )
    .all(req.params.id);
  res.json({ farm, products });
});

module.exports = router;
