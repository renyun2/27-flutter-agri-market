const express = require('express');
const db = require('../../db');

const router = express.Router();

router.get('/', (_req, res) => {
  const items = db.prepare('SELECT id, name, slug, cold_chain FROM categories ORDER BY name').all();
  res.json({ items });
});

module.exports = router;
