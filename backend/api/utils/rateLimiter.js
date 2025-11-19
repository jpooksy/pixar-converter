// Simple in-memory rate limiter
// For production, use Redis or a database
const requestCounts = new Map();

const RATE_LIMIT = {
  windowMs: 60 * 60 * 1000, // 1 hour
  maxRequests: 10 // 10 requests per hour per device/IP
};

function getRateLimitKey(req) {
  // Use device ID from header if available, otherwise use IP
  return req.headers['x-device-id'] || req.headers['x-forwarded-for'] || req.connection.remoteAddress;
}

function isRateLimited(key) {
  const now = Date.now();
  const userRequests = requestCounts.get(key) || { count: 0, resetTime: now + RATE_LIMIT.windowMs };

  // Reset if window has passed
  if (now > userRequests.resetTime) {
    userRequests.count = 0;
    userRequests.resetTime = now + RATE_LIMIT.windowMs;
  }

  // Check if over limit
  if (userRequests.count >= RATE_LIMIT.maxRequests) {
    return true;
  }

  // Increment and store
  userRequests.count++;
  requestCounts.set(key, userRequests);
  return false;
}

function checkRateLimit(req, res) {
  const key = getRateLimitKey(req);

  if (isRateLimited(key)) {
    res.status(429).json({
      error: 'Rate limit exceeded',
      message: 'Too many requests. Please try again later.',
      retryAfter: RATE_LIMIT.windowMs / 1000
    });
    return false;
  }

  return true;
}

module.exports = { checkRateLimit };
