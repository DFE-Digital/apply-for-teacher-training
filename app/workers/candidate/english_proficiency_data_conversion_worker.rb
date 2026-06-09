class Candidate::EnglishProficiencyDataConversionWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  queue_as :low_priority

  def perform
    EnglishProficiency.has_qualification.where(has_qualification: false).update_all(has_qualification: true)
    EnglishProficiency.no_qualification.where(no_qualification: false).update_all(no_qualification: true)
    EnglishProficiency.qualification_not_needed.where(qualification_not_needed: false).update_all(qualification_not_needed: true)
  end
end
