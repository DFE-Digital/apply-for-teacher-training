class UpdateDuplicateMatchesWorker < ApplicationJob
  queue_as :low_priority

  def perform
    UpdateDuplicateMatches.new.save!
  end
end
