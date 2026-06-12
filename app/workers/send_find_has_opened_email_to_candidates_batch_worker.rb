class SendFindHasOpenedEmailToCandidatesBatchWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  def perform(candidate_ids)
    Candidate.includes(:application_forms).where(id: candidate_ids).each do |candidate|
      SendFindHasOpenedEmailToCandidate.call(
        application_form: candidate.current_application,
      )
    end
  end
end
