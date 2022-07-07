class SendEocDeadlineReminderEmailToCandidatesBatchWorker
  include Sidekiq::Worker

  def perform(application_ids)
    ApplicationForm.where(id: application_ids).each do |application_form|
      SendEocDeadlineReminderEmailToCandidate.call(application_form: application_form)
    end
  end
end
