function addHours(iso, hours) {
  const d = new Date(iso);
  d.setHours(d.getHours() + hours);
  return d.toISOString().slice(0, 19);
}

function addDays(iso, days) {
  const d = new Date(iso);
  d.setDate(d.getDate() + days);
  return d.toISOString().slice(0, 10);
}

function nowIso() {
  return new Date().toISOString().slice(0, 19);
}

function todayStr() {
  return new Date().toISOString().slice(0, 10);
}

module.exports = { addHours, addDays, nowIso, todayStr };
