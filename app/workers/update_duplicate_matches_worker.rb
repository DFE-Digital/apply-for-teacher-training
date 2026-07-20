class UpdateDuplicateMatchesWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  queue_as :low_priority

  def perform
    UpdateDuplicateMatches.new.save!
  end
end
