class Candidate::DeleteDraftCandidatePreferencesWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low_priority

  def perform
    CandidatePreference.draft.where('updated_at < ?', 3.days.ago).delete_all
  end
end
