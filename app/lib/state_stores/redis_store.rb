module StateStores
  class RedisStore
    def initialize(key:)
      @key = key
    end

    def write(value, expires = 24.hours.to_i)
      Rails.cache.write(@key, value, expires_in: expires)
    end

    def read
      Rails.cache.read(@key)
    end

    def delete
      Rails.cache.delete(@key)
    end
  end
end
