class RetryDemoJob < ApplicationJob
  self.queue_adapter = :solid_queue

  queue_as :default

  retry_on StandardError, wait: 10.seconds, attempts: 3

  def perform(fail_until: 3)
    attempt = executions

    Rails.root.join('retry_demo.txt').open('a') do |file|
      file.puts "RetryDemoJob attempt #{attempt} at #{Time.now}"
    end

    return if attempt >= 5

    raise StandardError, 'Simulated failure' if attempt < fail_until

    Rails.root.join('retry_demo.txt').open('a') do |file|
      file.puts "RetryDemoJob succeeded on attempt #{attempt} at #{Time.now}"
    end
  end
end

# flow:
# solid_queue_ready_executions -> [picked up by worker] -> solid_queue_claimed_executions -> [fails and retries] -> solid_queue_scheduled_executions
