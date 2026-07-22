class Candidate::DeleteDraftCandidatePreferencesWorker < ApplicationJob
  queue_as :low_priority

  def perform
    CandidatePreference.draft.where('updated_at < ?', 3.days.ago).delete_all
  end
end
