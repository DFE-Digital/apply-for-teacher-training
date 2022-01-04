require 'redis'

module WizardStateStores
  class RedisStore < StateStores::RedisStore
    def write(value)
      super(value, 4.hours.to_i)
    end
  end
end
