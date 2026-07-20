class SendEocDeadlineReminderEmailToCandidatesBatchWorker
  include Sidekiq::Worker

  def perform(application_ids, chaser_type)
    ApplicationForm.where(id: application_ids).each do |application_form|
      SendEocDeadlineReminderEmailToCandidate.new(application_form:, chaser_type:).call
    end
  end
end
