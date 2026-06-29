class SendFindHasOpenedEmailToCandidatesBatchWorker < ApplicationJob
  def perform(candidate_ids)
    Candidate.includes(:application_forms).where(id: candidate_ids).find_each do |candidate|
      SendFindHasOpenedEmailToCandidate.call(
        application_form: candidate.current_application,
      )
    end
  end
end
