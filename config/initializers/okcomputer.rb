require 'teacher_training_public_api/sync_check'
require 'healthchecks'

OkComputer.mount_at = 'integrations/monitoring'

OkComputer::Registry.register 'notify', Healthchecks::NotifyCheck.new
OkComputer::Registry.register 'postgres', OkComputer::ActiveRecordCheck.new
OkComputer::Registry.register 'redis', OkComputer::RedisCheck.new(url: ENV['REDIS_URL'])
OkComputer::Registry.register 'simulated_failure', Healthchecks::SimulatedFailureCheck.new
OkComputer::Registry.register 'version', OkComputer::AppVersionCheck.new

OkComputer.make_optional %w[version]
