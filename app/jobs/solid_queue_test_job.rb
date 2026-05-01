class SolidQueueTestJob < ApplicationJob
  self.queue_adapter = :solid_queue

  queue_as :low_priority

  def perform
    ApplicationForm.last.update(updated_at: Time.zone.now)
  end
end
