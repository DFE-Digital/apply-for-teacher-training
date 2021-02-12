require 'redis'

module WizardStateStores
  class RedisStore
    def initialize(key:)
      @redis = Redis.current
      @key = key
    end

    def write(value)
      @redis.set(@key, value, ex: 4.hours.to_i)
    end

    def read
      @redis.get(@key)
    end

    def delete
      @redis.del(@key)
    end
  end
end
