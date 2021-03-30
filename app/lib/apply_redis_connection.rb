class ApplyRedisConnection
  HOST_AND_PORT = 'redis://localhost:6379'.freeze

  def self.url
    if ENV['REDIS_URL'].present?
      # Always use the Redis database defined by the environment, if available.
      ENV['REDIS_URL']
    elsif ENV.key?('VCAP_SERVICES')
      # When running on PaaS, the redis service is bound to the app and configuration is available under VCAP_SERVICES
      JSON.parse(ENV['VCAP_SERVICES'])['redis'][0]['credentials']['uri']
    elsif ENV['TEST_ENV_NUMBER']
      # If we're in the test environment and tests are being run in parallel,
      # use a different database for each process. Add 1 to the environment
      # number so that we don't clobber the development database at 0.
      database_number = ENV['TEST_ENV_NUMBER'].to_i + 1
      "#{HOST_AND_PORT}/#{database_number}"
    elsif Rails.env.test?
      # If we're in the test environment and tests are being run in a single
      # process, default to database 9 (this could be any number except 0).
      "#{HOST_AND_PORT}/9"
    else
      "#{HOST_AND_PORT}/0"
    end
  end
end
