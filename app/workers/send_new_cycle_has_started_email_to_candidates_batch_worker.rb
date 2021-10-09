class SendNewCycleHasStartedEmailToCandidatesBatchWorker
  include Sidekiq::Worker

  def perform(candidate_ids)
    Candidate.includes(:application_forms).where(id: candidate_ids).each do |candidate|
      application_form = candidate.current_application
      CandidateMailer.new_cycle_has_started(application_form).deliver_later
      ChaserSent.create!(chased: application_form, chaser_type: :new_cycle_has_started)
    end
  end
end
