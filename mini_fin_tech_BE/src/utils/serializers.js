function normalizeText(value) {
  return String(value || "").trim();
}

function normalizeCategory(value) {
  return normalizeText(value).toLowerCase();
}

module.exports = { normalizeText, normalizeCategory };
