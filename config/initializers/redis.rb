require './app/lib/apply_redis_connection'

Redis.current = Redis.new(url: ApplyRedisConnection.url)
