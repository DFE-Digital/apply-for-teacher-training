Rack::Attack.enabled = false

RSpec.configure do |config|
  config.around do |example|
    if example.metadata[:rack_attack] == true
      begin
        Rack::Attack.enabled = true
        Rack::Attack.reset!
        example.run
      ensure
        Rack::Attack.enabled = false
      end
    else
      example.run
    end
  end
end
