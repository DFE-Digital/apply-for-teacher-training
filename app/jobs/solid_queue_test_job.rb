class SolidQueueTestJob < ApplicationJob
  self.queue_adapter = :solid_queue

  def perform
    Rails.logger.info 'SolidQueueTestJob ran! 🙌 🙌 🙌 🙌'
  end
end
