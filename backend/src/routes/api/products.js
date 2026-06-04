const express = require('express');
const db = require('../../db');

const router = express.Router();

function mapProduct(row) {
  return {
    id: row.id,
    farm_id: row.farm_id,
    farm_name: row.farm_name,
    category_id: row.category_id,
    category_name: row.category_name,
    name: row.name,
    price: row.price,
    unit: row.unit,
    origin: row.origin,
    image_url: row.image_url,
    description: row.description,
    seasonal: row.seasonal,
    cold_chain: row.cold_chain,
  };
}

router.get('/', (req, res) => {
  const { farmId, origin, categoryId, q } = req.query;
  let sql = `
    SELECT p.*, f.name AS farm_name, c.name AS category_name, c.cold_chain
    FROM products p
    JOIN farms f ON f.id = p.farm_id
    JOIN categories c ON c.id = p.category_id
    WHERE 1=1`;
  const params = [];
  if (farmId) {
    sql += ' AND p.farm_id = ?';
    params.push(farmId);
  }
  if (origin) {
    sql += ' AND p.origin LIKE ?';
    params.push(`%${origin}%`);
  }
  if (categoryId) {
    sql += ' AND p.category_id = ?';
    params.push(categoryId);
  }
  if (q) {
    sql += ' AND (p.name LIKE ? OR p.origin LIKE ?)';
    params.push(`%${q}%`, `%${q}%`);
  }
  sql += ' ORDER BY p.name LIMIT 200';
  const rows = db.prepare(sql).all(...params);
  res.json({ items: rows.map(mapProduct) });
});

router.get('/:id/reports', (req, res) => {
  const product = db.prepare('SELECT id FROM products WHERE id = ?').get(req.params.id);
  if (!product) return res.status(404).json({ error: '商品不存在', code: 404 });
  const items = db
    .prepare('SELECT id, product_id, title, pdf_url FROM quality_reports WHERE product_id = ?')
    .all(req.params.id);
  res.json({ items });
});

router.get('/:id', (req, res) => {
  const row = db
    .prepare(
      `SELECT p.*, f.name AS farm_name, c.name AS category_name, c.cold_chain
       FROM products p
       JOIN farms f ON f.id = p.farm_id
       JOIN categories c ON c.id = p.category_id
       WHERE p.id = ?`
    )
    .get(req.params.id);
  if (!row) return res.status(404).json({ error: '商品不存在', code: 404 });
  const batches = db
    .prepare(
      'SELECT id, product_id, batch_no, harvest_date, trace_code FROM batches WHERE product_id = ?'
    )
    .all(req.params.id);
  res.json({ product: mapProduct(row), batches });
});

module.exports = router;
