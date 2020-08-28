require 'redis'

module WizardStateStores
  class RedisStore
    def initialize(key:)
      @redis = Redis.new
      @key = key
    end

    def write(value)
      @redis.set(@key, value, ex: ActiveSupport::Duration::SECONDS_PER_DAY)
    end

    def read
      @redis.get(@key)
    end

    def delete
      @redis.del(@key)
    end
  end
end
