class SendApplyToMultipleCoursesWhenInactiveEmailToCandidatesBatchWorker
  include Sidekiq::Worker

  def perform(application_ids)
    ApplicationForm.where(id: application_ids).each do |application_form|
      application_choices_ids = application_form.application_choices.inactive
                          .where(inactive_at: 1.day.ago..Time.zone.now).pluck(:id)
      SendApplyToMultipleCoursesWhenInactiveEmailToCandidate.call(application_form_id: application_form.id, application_choices_ids:)
    end
  end
end
