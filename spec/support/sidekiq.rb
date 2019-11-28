RSpec.configure do |config|
  config.around sidekiq: true do |example|
    Sidekiq::Testing.inline! do
      example.run
    end
  end
end
