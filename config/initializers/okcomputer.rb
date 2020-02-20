OkComputer.mount_at = 'integrations/monitoring'

OkComputer::Registry.register 'postgres', OkComputer::ActiveRecordCheck.new
OkComputer::Registry.register 'redis', OkComputer::RedisCheck.new(url: ENV['REDIS_URL'])
OkComputer::Registry.register 'sidekiq_default_queue', OkComputer::SidekiqLatencyCheck.new(queue: 'default', threshold: 100)
OkComputer::Registry.register 'sidekiq_mailers_queue', OkComputer::SidekiqLatencyCheck.new(queue: 'mailers', threshold: 100)
