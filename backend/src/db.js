const Database = require('better-sqlite3');
const fs = require('fs');
const path = require('path');

const dataDir = path.join(__dirname, '..', 'data');
if (!fs.existsSync(dataDir)) fs.mkdirSync(dataDir, { recursive: true });

const dbPath = process.env.AGRI_DB_PATH || path.join(dataDir, 'agri.db');
const db = new Database(dbPath);
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

function initSchema() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      phone TEXT NOT NULL UNIQUE,
      name TEXT NOT NULL,
      password TEXT NOT NULL DEFAULT '123456',
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS sessions (
      token TEXT PRIMARY KEY,
      user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      slug TEXT NOT NULL UNIQUE,
      cold_chain INTEGER NOT NULL DEFAULT 0
    );

    CREATE TABLE IF NOT EXISTS farms (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      story TEXT NOT NULL DEFAULT '',
      origin_region TEXT NOT NULL DEFAULT '',
      map_image_url TEXT NOT NULL DEFAULT ''
    );

    CREATE TABLE IF NOT EXISTS products (
      id TEXT PRIMARY KEY,
      farm_id TEXT NOT NULL REFERENCES farms(id),
      category_id TEXT NOT NULL REFERENCES categories(id),
      name TEXT NOT NULL,
      price REAL NOT NULL,
      unit TEXT NOT NULL DEFAULT '斤',
      origin TEXT NOT NULL DEFAULT '',
      image_url TEXT NOT NULL DEFAULT '',
      description TEXT NOT NULL DEFAULT '',
      seasonal INTEGER NOT NULL DEFAULT 0
    );

    CREATE TABLE IF NOT EXISTS batches (
      id TEXT PRIMARY KEY,
      product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
      batch_no TEXT NOT NULL,
      harvest_date TEXT NOT NULL,
      trace_code TEXT NOT NULL UNIQUE
    );

    CREATE TABLE IF NOT EXISTS trace_nodes (
      id TEXT PRIMARY KEY,
      batch_id TEXT NOT NULL REFERENCES batches(id) ON DELETE CASCADE,
      step INTEGER NOT NULL,
      title TEXT NOT NULL,
      detail TEXT NOT NULL DEFAULT '',
      location TEXT NOT NULL DEFAULT '',
      occurred_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS presales (
      id TEXT PRIMARY KEY,
      product_id TEXT NOT NULL REFERENCES products(id),
      title TEXT NOT NULL,
      full_price REAL NOT NULL,
      deposit_rate REAL NOT NULL DEFAULT 0.2,
      harvest_date TEXT NOT NULL,
      balance_due_at TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'open'
    );

    CREATE TABLE IF NOT EXISTS group_buys (
      id TEXT PRIMARY KEY,
      product_id TEXT NOT NULL REFERENCES products(id),
      leader_user_id TEXT NOT NULL REFERENCES users(id),
      status TEXT NOT NULL DEFAULT 'open',
      target_count INTEGER NOT NULL DEFAULT 3,
      member_count INTEGER NOT NULL DEFAULT 1,
      group_price REAL NOT NULL,
      expire_at TEXT NOT NULL,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS group_buy_members (
      group_buy_id TEXT NOT NULL REFERENCES group_buys(id) ON DELETE CASCADE,
      user_id TEXT NOT NULL REFERENCES users(id),
      joined_at TEXT NOT NULL DEFAULT (datetime('now')),
      PRIMARY KEY (group_buy_id, user_id)
    );

    CREATE TABLE IF NOT EXISTS cart_items (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      product_id TEXT NOT NULL REFERENCES products(id),
      batch_id TEXT REFERENCES batches(id),
      qty INTEGER NOT NULL DEFAULT 1
    );

    CREATE TABLE IF NOT EXISTS orders (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL REFERENCES users(id),
      order_type TEXT NOT NULL DEFAULT 'normal',
      status TEXT NOT NULL DEFAULT 'pending_payment',
      parent_id TEXT REFERENCES orders(id),
      presale_id TEXT REFERENCES presales(id),
      group_buy_id TEXT REFERENCES group_buys(id),
      items_json TEXT NOT NULL DEFAULT '[]',
      subtotal REAL NOT NULL DEFAULT 0,
      cold_chain_fee REAL NOT NULL DEFAULT 0,
      discount REAL NOT NULL DEFAULT 0,
      total_amount REAL NOT NULL DEFAULT 0,
      deposit_amount REAL NOT NULL DEFAULT 0,
      balance_amount REAL NOT NULL DEFAULT 0,
      balance_due_at TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      paid_at TEXT
    );

    CREATE TABLE IF NOT EXISTS subscriptions (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      name TEXT NOT NULL,
      frequency TEXT NOT NULL CHECK(frequency IN ('weekly','monthly')),
      items_json TEXT NOT NULL DEFAULT '[]',
      next_delivery_at TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'active',
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS quality_reports (
      id TEXT PRIMARY KEY,
      product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
      title TEXT NOT NULL,
      pdf_url TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS coupons (
      id TEXT PRIMARY KEY,
      code TEXT NOT NULL UNIQUE,
      title TEXT NOT NULL,
      discount REAL NOT NULL,
      min_amount REAL NOT NULL DEFAULT 0,
      expires_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS user_coupons (
      user_id TEXT NOT NULL REFERENCES users(id),
      coupon_id TEXT NOT NULL REFERENCES coupons(id),
      claimed_at TEXT NOT NULL DEFAULT (datetime('now')),
      used INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (user_id, coupon_id)
    );
  `);
}

initSchema();

module.exports = db;
