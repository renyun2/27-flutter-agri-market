const { v4: uuid } = require('uuid');
const db = require('./db');
const { addDays, addHours, todayStr } = require('./utils/date');

const CATEGORIES = [
  { name: '时令果蔬', slug: 'fruit-veg', cold: 0 },
  { name: '粮油干货', slug: 'grain', cold: 0 },
  { name: '肉禽蛋品', slug: 'meat-egg', cold: 0 },
  { name: '冷冻海鲜', slug: 'frozen-seafood', cold: 1 },
  { name: '有机蔬菜', slug: 'organic', cold: 0 },
];

const REGIONS = ['山东寿光', '云南元谋', '陕西洛川', '新疆阿克苏', '海南乐东', '四川蒲江', '广西百色', '黑龙江五常'];

const PRODUCE = [
  '红富士苹果', '砂糖橘', '阳光玫瑰葡萄', '草莓', '西红柿', '黄瓜', '土豆', '大米',
  '五常糯米', '土鸡蛋', '散养土鸡', '冷鲜带鱼', '冷冻虾仁', '有机菠菜', '西兰花',
  '紫薯', '红薯', '核桃', '蜂蜜', '茶叶', '香菇', '木耳', '玉米', '高粱', '花生',
];

const FARMS = [
  { name: '绿野田园合作社', story: '坚持有机种植十年，产地直供。' },
  { name: '山谷果园', story: '高海拔昼夜温差大，果品糖度高。' },
  { name: '稻香农家', story: '五常核心产区，一年一季稻。' },
  { name: '海滨渔场', story: '冷链直达，海鲜当日上岸。' },
  { name: '阳光蔬菜基地', story: '温室无土栽培，全年供应。' },
  { name: '云端茶园', story: '高山云雾茶，手工采摘。' },
  { name: '果香人家', story: '家族果园三代传承。' },
  { name: '沃土农庄', story: '生态循环农业示范户。' },
  { name: '清泉蜂场', story: '深山野花蜜，零添加。' },
  { name: '金穗粮油', story: '非转基因，现磨现发。' },
  { name: '河畔鲜蔬', story: '黄河滩区沙壤菜。' },
  { name: '岭南果业', story: '热带水果当季采摘。' },
];

const TRACE_STEPS = [
  { title: '种植', detail: '播种、施肥记录已上链' },
  { title: '采摘', detail: '人工采摘，农残检测合格' },
  { title: '质检', detail: '第三方质检报告已归档' },
  { title: '物流', detail: '冷链/常温运输中' },
];

function seed() {
  const count = db.prepare('SELECT COUNT(*) AS c FROM users').get().c;
  if (count > 0) return;

  const userId = uuid();
  db.prepare('INSERT INTO users (id, phone, name, password) VALUES (?,?,?,?)').run(
    userId,
    '13800138000',
    '农品用户',
    '123456'
  );

  const catIds = {};
  const insCat = db.prepare(
    'INSERT INTO categories (id, name, slug, cold_chain) VALUES (?,?,?,?)'
  );
  CATEGORIES.forEach((c) => {
    const id = uuid();
    catIds[c.slug] = id;
    insCat.run(id, c.name, c.slug, c.cold ? 1 : 0);
  });

  const farmIds = [];
  const insFarm = db.prepare(
    'INSERT INTO farms (id, name, story, origin_region, map_image_url) VALUES (?,?,?,?,?)'
  );
  FARMS.forEach((f, i) => {
    const id = uuid();
    farmIds.push(id);
    const region = REGIONS[i % REGIONS.length];
    insFarm.run(
      id,
      f.name,
      f.story,
      region,
      `https://pics.example/map/${i + 1}.jpg`
    );
  });

  const insProduct = db.prepare(
    `INSERT INTO products (id, farm_id, category_id, name, price, unit, origin, image_url, description, seasonal)
     VALUES (?,?,?,?,?,?,?,?,?,?)`
  );
  const insBatch = db.prepare(
    'INSERT INTO batches (id, product_id, batch_no, harvest_date, trace_code) VALUES (?,?,?,?,?)'
  );
  const insNode = db.prepare(
    'INSERT INTO trace_nodes (id, batch_id, step, title, detail, location, occurred_at) VALUES (?,?,?,?,?,?,?)'
  );

  const productIds = [];
  let pi = 0;
  while (productIds.length < 62) {
    pi += 1;
    const name = PRODUCE[(pi - 1) % PRODUCE.length] + (pi > PRODUCE.length ? ` ${Math.floor(pi / PRODUCE.length)}号` : '');
    const id = uuid();
    productIds.push(id);
    const farmId = farmIds[pi % farmIds.length];
    const slugKeys = Object.keys(catIds);
    const catSlug = slugKeys[pi % slugKeys.length];
    const categoryId = catIds[catSlug];
    const origin = REGIONS[pi % REGIONS.length];
    const price = 8 + (pi % 20) * 2.5;
    insProduct.run(
      id,
      farmId,
      categoryId,
      name,
      Math.round(price * 100) / 100,
      pi % 5 === 0 ? '盒' : '斤',
      origin,
      `https://pics.example/agri/${pi}.jpg`,
      `${origin}直供 ${name}`,
      pi % 4 === 0 ? 1 : 0
    );
    for (let b = 1; b <= 2; b += 1) {
      const batchId = uuid();
      const traceCode = `AGRI-${String(pi).padStart(3, '0')}-${b}`;
      const harvest = addDays(todayStr(), -7 - b);
      insBatch.run(batchId, id, `B${pi}-${b}`, harvest, traceCode);
      TRACE_STEPS.forEach((step, si) => {
        insNode.run(
          uuid(),
          batchId,
          si + 1,
          step.title,
          step.detail,
          origin,
          addDays(harvest, si)
        );
      });
    }
  }

  const insPresale = db.prepare(
    `INSERT INTO presales (id, product_id, title, full_price, deposit_rate, harvest_date, balance_due_at, status)
     VALUES (?,?,?,?,?,?,?,?)`
  );
  productIds.slice(0, 8).forEach((pid, i) => {
    const p = db.prepare('SELECT name, price FROM products WHERE id = ?').get(pid);
    const harvest = addDays(todayStr(), 30 + i);
    const balanceDue = addDays(harvest, -3);
    insPresale.run(
      uuid(),
      pid,
      `${p.name} 季节性预售`,
      p.price * 2,
      0.2,
      harvest,
      balanceDue,
      'open'
    );
  });

  const insCoupon = db.prepare(
    'INSERT INTO coupons (id, code, title, discount, min_amount, expires_at) VALUES (?,?,?,?,?,?)'
  );
  insCoupon.run(uuid(), 'AGRI10', '满50减10', 10, 50, addDays(todayStr(), 90));
  insCoupon.run(uuid(), 'COLD5', '冷链专享减5', 5, 30, addDays(todayStr(), 60));

  const insReport = db.prepare(
    'INSERT INTO quality_reports (id, product_id, title, pdf_url) VALUES (?,?,?,?)'
  );
  productIds.slice(0, 15).forEach((pid) => {
    insReport.run(uuid(), pid, '农残与重金属检测报告', `https://pics.example/report/${pid.slice(0, 8)}.pdf`);
  });

  const openGroup = uuid();
  const sampleProduct = productIds[0];
  const samplePrice = db.prepare('SELECT price FROM products WHERE id = ?').get(sampleProduct).price;
  db.prepare(
    `INSERT INTO group_buys (id, product_id, leader_user_id, member_count, group_price, expire_at, status)
     VALUES (?,?,?,?,?,?,?)`
  ).run(
    openGroup,
    sampleProduct,
    userId,
    2,
    Math.round(samplePrice * 0.85 * 100) / 100,
    addHours(new Date().toISOString().slice(0, 19), 20),
    'open'
  );
  db.prepare('INSERT INTO group_buy_members (group_buy_id, user_id) VALUES (?,?)').run(
    openGroup,
    userId
  );
  const user2 = uuid();
  db.prepare('INSERT INTO users (id, phone, name, password) VALUES (?,?,?,?)').run(
    user2,
    '13900139000',
    '拼团用户B',
    '123456'
  );
  db.prepare('INSERT INTO group_buy_members (group_buy_id, user_id) VALUES (?,?)').run(
    openGroup,
    user2
  );
}

if (require.main === module) {
  seed();
  console.log('Agri market seed complete');
}

module.exports = { seed };
