module EndOfCycle
  class SendApplicationDeadlineHasPassedEmailToCandidatesWorker < ApplicationJob
    self.queue_adapter = :solid_queue

    BATCH_SIZE = 120

    def perform
      return unless EndOfCycle::CandidateEmailTimetabler.new.send_application_deadline_has_passed_email?

      BatchDelivery.new(relation:, batch_size: BATCH_SIZE).each do |batch_time, application_forms|
        SendApplicationDeadlineHasPassedEmailToCandidatesBatchWorker.perform_at(batch_time, application_forms.pluck(:id))
      end
    end

    def relation
      ApplicationForm
        .current_cycle
        .joins(:candidate).merge(Candidate.for_transaction_emails)
        .unsubmitted
        .distinct
    end
  end

  class SendApplicationDeadlineHasPassedEmailToCandidatesBatchWorker < ApplicationJob
    self.queue_adapter = :solid_queue

    def perform(application_form_ids)
      ApplicationForm.where(id: application_form_ids).find_each do |application_form|
        CandidateMailer.application_deadline_has_passed(application_form).deliver_later
      end
    end
  end
end
