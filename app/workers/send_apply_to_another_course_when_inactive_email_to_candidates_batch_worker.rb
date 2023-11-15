class SendApplyToAnotherCourseWhenInactiveEmailToCandidatesBatchWorker
  include Sidekiq::Worker

  def perform(application_ids)
    ApplicationForm.where(id: application_ids).each do |application_form|
      application_choice = application_form.application_choices.inactive
                          .find_by(inactive_at: 1.day.ago..Time.zone.now)

      SendApplyToAnotherCourseWhenInactiveEmailToCandidate.call(application_choice:)
    end
  end
end
