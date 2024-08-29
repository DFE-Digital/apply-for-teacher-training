module EndOfCycle
  class SendApplicationDeadlineHasPassedEmailToCandidatesWorker
    include Sidekiq::Worker

    BATCH_SIZE = 120

    def perform
      return unless send_application_deadline_has_passed_email_to_candidates?

      BatchDelivery.new(relation:, batch_size: BATCH_SIZE).each do |batch_time, application_forms|
        SendApplicationDeadlineHasPassedEmailToCandidatesBatchWorker.perform_at(batch_time, application_forms.pluck(:id))
      end
    end

    def relation
      ApplicationForm
        .joins(:candidate)
        .where(candidates: { submission_blocked: false, account_locked: false })
        .current_cycle
        .unsubmitted
        .distinct
    end

  private

    def send_application_deadline_has_passed_email_to_candidates?
      CycleTimetable.send_application_deadline_has_passed_email_to_candidates?
    end
  end

  class SendApplicationDeadlineHasPassedEmailToCandidatesBatchWorker
    include Sidekiq::Worker

    def perform(application_form_ids)
      ApplicationForm.where(id: application_form_ids).find_each do |application_form|
        CandidateMailer.application_deadline_has_passed(application_form).deliver_later
      end
    end
  end
end
