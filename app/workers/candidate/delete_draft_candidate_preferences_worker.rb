class Candidate::DeleteDraftCandidatePreferencesWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  def perform
    CandidatePreference.draft.where('updated_at < ?', 3.days.ago).delete_all
  end
end
