require 'teacher_training_public_api/sync_check'

class SimulatedFailureCheck < OkComputer::Check
  def check
    if FeatureFlag.active?('force_ok_computer_to_fail')
      mark_failure
      mark_message 'force_ok_computer_to_fail is on'
    else
      mark_message 'force_ok_computer_to_fail is off'
    end
  end
end

class SidekiqRetriesCheck < OkComputer::Check
  def check
    retries_queue_length = Sidekiq::RetrySet.new.size
    queue_length_text = " (#{retries_queue_length})"
    if retries_queue_length > 50
      mark_failure
      mark_message "Sidekiq pending retries depth is high #{queue_length_text}. Suggests high error rate"
    else
      mark_message 'Sidekiq pending retries depth at reasonable level' + queue_length_text
    end
  end
end

OkComputer.mount_at = 'integrations/monitoring'

OkComputer::Registry.register 'postgres', OkComputer::ActiveRecordCheck.new
OkComputer::Registry.register 'redis', OkComputer::RedisCheck.new(url: ApplyRedisConnection.url)
OkComputer::Registry.register 'sidekiq_default_queue', OkComputer::SidekiqLatencyCheck.new(queue: 'default', threshold: 100) # threshold in seconds
OkComputer::Registry.register 'sidekiq_mailers_queue', OkComputer::SidekiqLatencyCheck.new(queue: 'mailers', threshold: 100) # threshold in seconds
OkComputer::Registry.register 'sidekiq_retries_count', SidekiqRetriesCheck.new
OkComputer::Registry.register 'simulated_failure', SimulatedFailureCheck.new
OkComputer::Registry.register 'ttapi_sync', TeacherTrainingPublicAPI::SyncCheck.new
OkComputer::Registry.register 'version', OkComputer::AppVersionCheck.new

OkComputer.make_optional %w[version]
