class SendApplyToMultipleCoursesWhenInactiveEmailToCandidatesBatchWorker
  include Sidekiq::Worker

  def perform(application_ids)
    ApplicationForm.where(id: application_ids).each do |application_form|
      SendApplyToMultipleCoursesWhenInactiveEmailToCandidate.call(application_form)
    end
  end
end
