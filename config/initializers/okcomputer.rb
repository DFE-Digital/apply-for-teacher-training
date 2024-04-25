require 'healthchecks'

OkComputer.mount_at = 'integrations/monitoring'

OkComputer::Registry.register 'notify', Healthchecks::NotifyCheck.new(force_pass: Rails.env.test?)
OkComputer::Registry.register 'postgres', OkComputer::ActiveRecordCheck.new
OkComputer::Registry.register 'redis', OkComputer::RedisCheck.new(url: ENV['REDIS_URL'])
OkComputer::Registry.register 'simulated_failure', Healthchecks::SimulatedFailureCheck.new
OkComputer::Registry.register 'version', OkComputer::AppVersionCheck.new

OkComputer.make_optional %w[version]
