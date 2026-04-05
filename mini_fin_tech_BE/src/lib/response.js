function sendSuccess(res, statusCode, data, meta) {
  const payload = { data };
  if (meta) {
    payload.meta = meta;
  }

  return res.status(statusCode).json(payload);
}

module.exports = { sendSuccess };
