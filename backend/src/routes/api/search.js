const express = require('express');
const db = require('../../db');

const router = express.Router();

router.get('/', (req, res) => {
  const q = (req.query.q || '').trim();
  if (!q) return res.json({ items: [], farms: [] });
  const items = db
    .prepare(
      `SELECT p.id, p.name, p.price, p.unit, p.origin, p.image_url, f.name AS farm_name
       FROM products p JOIN farms f ON f.id = p.farm_id
       WHERE p.name LIKE ? OR p.origin LIKE ? OR f.name LIKE ?
       LIMIT 40`
    )
    .all(`%${q}%`, `%${q}%`, `%${q}%`);
  const farms = db
    .prepare(
      `SELECT id, name, origin_region FROM farms
       WHERE name LIKE ? OR origin_region LIKE ? LIMIT 10`
    )
    .all(`%${q}%`, `%${q}%`);
  res.json({ items, farms, query: q });
});

module.exports = router;
