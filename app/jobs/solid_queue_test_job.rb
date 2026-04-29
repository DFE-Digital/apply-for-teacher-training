class SolidQueueTestJob < ApplicationJob
  self.queue_adapter = :solid_queue

  def perform
    Rails.root.join('test_success.txt').write("✅ Solid Queue job ran successfully at #{Time.current}\n")
  end
end
