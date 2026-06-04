const express = require('express');
const db = require('../../db');

const router = express.Router();

router.get('/:code', (req, res) => {
  const code = (req.params.code || '').trim().toUpperCase();
  const batch = db
    .prepare(
      `SELECT b.*, p.name AS product_name, p.origin, f.name AS farm_name
       FROM batches b
       JOIN products p ON p.id = b.product_id
       JOIN farms f ON f.id = p.farm_id
       WHERE UPPER(b.trace_code) = ?`
    )
    .get(code);
  if (!batch) return res.status(404).json({ error: '溯源码无效', code: 404 });

  const nodes = db
    .prepare(
      `SELECT id, step, title, detail, location, occurred_at
       FROM trace_nodes WHERE batch_id = ? ORDER BY step ASC`
    )
    .all(batch.id);

  res.json({
    trace_code: batch.trace_code,
    batch: {
      id: batch.id,
      batch_no: batch.batch_no,
      harvest_date: batch.harvest_date,
      product_id: batch.product_id,
      product_name: batch.product_name,
      origin: batch.origin,
      farm_name: batch.farm_name,
    },
    nodes,
  });
});

module.exports = router;
