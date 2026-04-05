function startOfWeek(date) {
  const result = new Date(date);
  const day = result.getDay();
  const diff = day === 0 ? -6 : 1 - day;
  result.setDate(result.getDate() + diff);
  result.setHours(0, 0, 0, 0);
  return result;
}

function startOfMonth(date) {
  return new Date(date.getFullYear(), date.getMonth(), 1);
}

function endOfMonth(date) {
  return new Date(date.getFullYear(), date.getMonth() + 1, 0, 23, 59, 59, 999);
}

function daysBetween(first, second) {
  const msPerDay = 24 * 60 * 60 * 1000;
  return Math.ceil((second.getTime() - first.getTime()) / msPerDay);
}

module.exports = {
  startOfWeek,
  startOfMonth,
  endOfMonth,
  daysBetween
};
