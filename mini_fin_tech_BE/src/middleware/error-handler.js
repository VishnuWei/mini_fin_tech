function notFoundHandler(req, res) {
  res.status(404).json({
    error: {
      code: "NOT_FOUND",
      message: `Route not found: ${req.method} ${req.originalUrl}`
    }
  });
}

function errorHandler(err, _req, res, _next) {
  const statusCode = err.statusCode || 500;

  res.status(statusCode).json({
    error: {
      code: err.name || "INTERNAL_SERVER_ERROR",
      message: err.message || "Something went wrong",
      details: err.details || undefined
    }
  });
}

module.exports = { notFoundHandler, errorHandler };
