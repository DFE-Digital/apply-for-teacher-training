class Candidate::EnglishProficiencyDataConversionWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  queue_as :low_priority

  def perform
    EnglishProficiency.has_qualification.where.not(has_qualification: true).update_all(has_qualification: true)
    EnglishProficiency.no_qualification.where.not(no_qualification: true).update_all(no_qualification: true)
    EnglishProficiency.qualification_not_needed.where.not(qualification_not_needed: true).update_all(qualification_not_needed: true)
  end
end
