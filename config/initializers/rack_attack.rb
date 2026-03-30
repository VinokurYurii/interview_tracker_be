# frozen_string_literal: true

# Rack::Attack — rate limiting middleware.
# Operates at the Rack level, filtering requests BEFORE they reach Rails controllers.
# Counters are stored in Redis for persistence across app restarts and deploys.
Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
  url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
)

class Rack::Attack
  # ============================================================================
  # Throttle: registration
  # ============================================================================
  # Max 5 signup attempts per IP per hour.
  # Protects against mass account creation by bots.
  # Returns 429 (Too Many Requests) when the limit is exceeded.
  throttle('registrations/ip', limit: 5, period: 1.hour) do |req|
    # Only count POST requests to the registration endpoint.
    # req.ip — client IP address (uses X-Forwarded-For when behind a proxy).
    req.ip if req.path == '/api/signup' && req.post?
  end

  # ============================================================================
  # Throttle: login
  # ============================================================================
  # Max 10 login attempts per IP per minute.
  # Protects against brute-force password attacks.
  throttle('logins/ip', limit: 10, period: 1.minute) do |req|
    req.ip if req.path == '/api/login' && req.post?
  end

  # ============================================================================
  # Throttle: general rate limit per IP
  # ============================================================================
  # Max 100 requests per IP per minute across all endpoints.
  # General protection against DDoS/spam. 100 req/min is more than enough
  # for normal usage.
  throttle('requests/ip', limit: 100, period: 1.minute) do |req|
    req.ip
  end

  # ============================================================================
  # Throttled response
  # ============================================================================
  # When a limit is exceeded, return 429 with a JSON body and a Retry-After
  # header telling the client how many seconds to wait before retrying.
  self.throttled_responder = lambda do |matched, period, limit, count, env|
    now = Time.now.utc
    retry_after = (period - (now.to_i % period)).to_s

    [
      429,
      {
        'Content-Type' => 'application/json',
        'Retry-After' => retry_after
      },
      [{ error: 'Too many requests. Please try again later.' }.to_json]
    ]
  end
end
