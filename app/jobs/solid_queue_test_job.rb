class SolidQueueTestJob < ApplicationJob
  self.queue_adapter = :solid_queue

  def perform
    Rails.root.join('test_success.txt').open('a') do |file|
      file.puts "✅ Solid Queue job ran successfully at #{Time.current}"
    end
  end
end
