module EndOfCycle
  class SendApplicationDeadlineHasPassedEmailToCandidatesWorker < ApplicationJob
    BATCH_SIZE = 120

    def perform
      return unless EndOfCycle::CandidateEmailTimetabler.new.send_application_deadline_has_passed_email?

      BatchDelivery.new(relation:, batch_size: BATCH_SIZE).each do |batch_time, application_forms|
        SendApplicationDeadlineHasPassedEmailToCandidatesBatchWorker.set(wait_until: batch_time).perform_later(application_forms.pluck(:id))
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
    def perform(application_form_ids)
      ApplicationForm.where(id: application_form_ids).find_each do |application_form|
        CandidateMailer.application_deadline_has_passed(application_form).deliver_later
      end
    end
  end
end
