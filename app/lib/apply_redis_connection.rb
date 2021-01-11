class ApplyRedisConnection
  def self.url
    if ENV['REDIS_URL'].present?
      # Always use the Redis database defined by the environment, if available.
      ENV['REDIS_URL']
    elsif ENV['TEST_ENV_NUMBER']
      # If we're in the test environment and tests are being run in parallel,
      # use a different database for each process. Add 1 to the environment
      # number so that we don't clobber the development database at 0.
      "redis://localhost:6379/#{ENV['TEST_ENV_NUMBER'].to_i + 1}"
    elsif Rails.env.test?
      # If we're in the test environment and tests are being run in a single
      # process, default to database 9 (this could be any number except 0).
      'redis://localhost:6379/9'
    else
      'redis://localhost:6379/0'
    end
  end
end
