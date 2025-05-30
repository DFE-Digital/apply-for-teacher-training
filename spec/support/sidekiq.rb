ActiveJob::Base.queue_adapter = :test

RSpec.configure do |config|
  include ActiveJob::TestHelper

  # If running tests in parallel, use a unique Redis database per test process.
  # See https://github.com/grosser/parallel_tests#add-to-configdatabaseyml
  if ENV.key?('TEST_ENV_NUMBER')
    redis_url_without_database = ENV['REDIS_URL']&.gsub(/\/\d+$/, '') || 'redis://localhost:6379'
    redis_db_index = (ENV['TEST_ENV_NUMBER'].presence || 1).to_i - 1
    redis_url_with_database = "#{redis_url_without_database}/#{redis_db_index}"

    if ENV['DEBUG_REDIS_CONNECTIONS']
      # Show the Redis connections being used when running tests in parallel
      logger.info "Using Redis database URL `#{redis_url_with_database}`"
      config.before { Sidekiq.redis { |c| logger.info c } }
    end

    config.around do |example|
      ClimateControl.modify(REDIS_URL: redis_url_with_database) do
        example.run
      end
    end
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
