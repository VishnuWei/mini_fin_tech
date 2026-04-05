function roundCurrency(value) {
  return Math.round((value + Number.EPSILON) * 100) / 100;
}

function sumAmounts(items, accessor = (item) => item.amount) {
  return roundCurrency(items.reduce((sum, item) => sum + Number(accessor(item) || 0), 0));
}

module.exports = { roundCurrency, sumAmounts };
