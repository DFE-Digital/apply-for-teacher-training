class ScheduledTestJob < ApplicationJob
  self.queue_adapter = :solid_queue

  queue_as :low_priority

  def perform
    Rails.root.join('scheduled_test_success.txt').open('a') do |file|
      file.puts "✅ Solid Queue job ran successfully at #{Time.current}"
    end
  end
end
