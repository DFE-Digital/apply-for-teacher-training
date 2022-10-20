Rack::Attack.enabled = false

RSpec.configure do |config|
  config.around do |example|
    if example.metadata[:rack_attack] == true
      begin
        previous_cache_store = Rack::Attack.cache.store
        Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
        Rack::Attack.enabled = true
        Rack::Attack.reset!
        example.run
      ensure
        Rack::Attack.cache.store = previous_cache_store
        Rack::Attack.enabled = false
      end
    else
      example.run
    end
  end
end
