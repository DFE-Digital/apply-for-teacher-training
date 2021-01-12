ActiveJob::Base.queue_adapter = :test

RSpec.configure do |config|
  include ActiveJob::TestHelper

  # Show the Redis connections being used when running tests in parallel
  if ENV['TEST_ENV_NUMBER'] && ENV['DEBUG_REDIS_CONNECTIONS']
    Sidekiq.redis { |c| p c }
  end

  # Turn Sidekiq on automatically in system tests. Use `sidekiq: false` in
  # tests to avoid Sidekiq running.
  config.define_derived_metadata(file_path: Regexp.new('/spec/system/')) do |metadata|
    metadata[:sidekiq] = true unless metadata[:sidekiq] == false
  end

  # Use `sidekiq: true` to run jobs immediately
  config.around sidekiq: true do |example|
    perform_enqueued_jobs do
      Sidekiq::Testing.inline! do
        example.run
      end
    end
  end
end
