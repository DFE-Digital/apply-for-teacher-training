require 'redis'

module StateStores
  class RedisStore
    def initialize(key:)
      @redis = Redis.current
      @key = key
    end

    def write(value, expires = 24.hours.to_i)
      @redis.set(@key, value, ex: expires)
    end

    def read
      @redis.get(@key)
    end

    def delete
      @redis.del(@key)
    end
  end
end
