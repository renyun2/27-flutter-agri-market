const db = require('../db');

const COLD_CHAIN_FEE = 12;

function categoryNeedsColdChain(categoryId) {
  const row = db.prepare('SELECT cold_chain FROM categories WHERE id = ?').get(categoryId);
  return row?.cold_chain === 1;
}

function calcColdChainFee(productIds) {
  if (!productIds.length) return 0;
  const placeholders = productIds.map(() => '?').join(',');
  const rows = db
    .prepare(
      `SELECT DISTINCT c.cold_chain FROM products p
       JOIN categories c ON c.id = p.category_id
       WHERE p.id IN (${placeholders})`
    )
    .all(...productIds);
  const needs = rows.some((r) => r.cold_chain === 1);
  return needs ? COLD_CHAIN_FEE : 0;
}

module.exports = { COLD_CHAIN_FEE, categoryNeedsColdChain, calcColdChainFee };
