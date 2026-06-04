const { test, before, after, describe } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const path = require('path');

const dbPath = path.join(__dirname, '..', 'data', `agri-test-${process.pid}.db`);

async function callApp(app, method, url, { token, body } = {}) {
  return new Promise((resolve, reject) => {
    const server = app.listen(0, () => {
      const { port } = server.address();
      const http = require('http');
      const payload = body ? JSON.stringify(body) : null;
      const req = http.request(
        {
          hostname: '127.0.0.1',
          port,
          path: url,
          method,
          headers: {
            'Content-Type': 'application/json',
            ...(token ? { Authorization: `Bearer ${token}` } : {}),
            ...(payload ? { 'Content-Length': Buffer.byteLength(payload) } : {}),
          },
        },
        (res) => {
          let raw = '';
          res.on('data', (c) => (raw += c));
          res.on('end', () => {
            server.close();
            resolve({
              status: res.statusCode,
              body: raw ? JSON.parse(raw) : null,
            });
          });
        }
      );
      req.on('error', (e) => {
        server.close();
        reject(e);
      });
      if (payload) req.write(payload);
      req.end();
    });
  });
}

function resetDb() {
  try {
    const dbModulePath = require.resolve('../src/db');
    if (require.cache[dbModulePath]) {
      require.cache[dbModulePath].exports.close();
      delete require.cache[dbModulePath];
    }
  } catch (_) {
    // ignore
  }
  ['../src/seed', '../src/index', '../src/utils/groupBuy'].forEach((p) => {
    try {
      delete require.cache[require.resolve(p)];
    } catch (_) {
      // ignore
    }
  });
  if (fs.existsSync(dbPath)) {
    try {
      fs.unlinkSync(dbPath);
    } catch (_) {
      // Windows lock
    }
  }
}

describe('Agri Market API', () => {
  let app;
  let token;
  let productId;
  let traceCode;
  let presaleId;

  before(() => {
    process.env.AGRI_DB_PATH = dbPath;
    resetDb();
    const { seed } = require('../src/seed');
    seed();
    app = require('../src/index');
    const db = require('../src/db');
    productId = db.prepare('SELECT id FROM products LIMIT 1').get().id;
    traceCode = db.prepare('SELECT trace_code FROM batches LIMIT 1').get().trace_code;
    presaleId = db.prepare('SELECT id FROM presales LIMIT 1').get().id;
  });

  after(() => {
    try {
      require('../src/db').close();
    } catch (_) {
      // ignore
    }
    delete require.cache[require.resolve('../src/db')];
    delete require.cache[require.resolve('../src/index')];
    try {
      if (fs.existsSync(dbPath)) fs.unlinkSync(dbPath);
    } catch (_) {
      // ignore
    }
  });

  test('login default user', async () => {
    const res = await callApp(app, 'POST', '/api/auth/login', {
      body: { phone: '13800138000', password: '123456' },
    });
    assert.equal(res.status, 200);
    token = res.body.token;
  });

  test('trace code returns timeline', async () => {
    const ok = await callApp(app, 'GET', `/api/trace/${traceCode}`);
    assert.equal(ok.status, 200);
    assert.ok(ok.body.nodes.length >= 4);
    const bad = await callApp(app, 'GET', '/api/trace/INVALID-CODE');
    assert.equal(bad.status, 404);
  });

  test('group buy completes at 3 members', async () => {
    const created = await callApp(app, 'POST', '/api/group-buys', {
      token,
      body: { productId, action: 'create' },
    });
    assert.equal(created.status, 201);
    const gid = created.body.group_buy.id;

    const u2 = await callApp(app, 'POST', '/api/auth/register', {
      body: { phone: `137${Date.now().toString().slice(-8)}`, password: '123456' },
    });
    const u3 = await callApp(app, 'POST', '/api/auth/register', {
      body: { phone: `136${(Date.now() + 1).toString().slice(-8)}`, password: '123456' },
    });

    const j2 = await callApp(app, 'POST', '/api/group-buys', {
      token: u2.body.token,
      body: { action: 'join', groupBuyId: gid },
    });
    assert.equal(j2.status, 200);

    const j3 = await callApp(app, 'POST', '/api/group-buys', {
      token: u3.body.token,
      body: { action: 'join', groupBuyId: gid },
    });
    assert.equal(j3.status, 200);
    assert.equal(j3.body.group_buy.status, 'completed');
    assert.equal(j3.body.group_buy.member_count, 3);
  });

  test('presale deposit and balance orders', async () => {
    const deposit = await callApp(app, 'POST', `/api/presales/${presaleId}/deposit`, { token });
    assert.equal(deposit.status, 201);
    assert.equal(deposit.body.order.order_type, 'presale_deposit');

    const payDeposit = await callApp(app, 'POST', `/api/orders/${deposit.body.order.id}/pay`, {
      token,
    });
    assert.equal(payDeposit.status, 200);

    const db = require('../src/db');
    const balance = db
      .prepare(
        `SELECT * FROM orders WHERE parent_id = ? AND order_type = 'presale_balance'`
      )
      .get(deposit.body.order.id);
    assert.ok(balance);

    const payBalance = await callApp(app, 'POST', `/api/orders/${balance.id}/pay-balance`, {
      token,
    });
    assert.equal(payBalance.status, 200);
    assert.equal(payBalance.body.order.status, 'paid');
  });
});
