class SolidQueueTestJob < ApplicationJob
  self.queue_adapter = :solid_queue

  def perform
    Rails.root.join('test_success.txt').open('a') do |file|
      file.puts "✅ Solid Queue job ran successfully at #{Time.current}"
    end
  end

  # def perform
  #   ApplicationForm.last.update(updated_at: Time.zone.now)
  # end
end
