module EndOfCycle
  class SendDeclineByDefaultExplainerEmailToCandidatesWorker < ApplicationJob
    BATCH_SIZE = 120

    def perform
      return unless CandidateEmailTimetabler.new.send_decline_by_default_explainer?

      BatchDelivery.new(relation:, batch_size: BATCH_SIZE).each do |batch_time, application_forms|
        SendDeclineByDefaultExplainerEmailToCandidatesBatchWorker.perform_at(batch_time, application_forms.pluck(:id))
      end
    end

    def relation
      ApplicationForm
        .current_cycle
        .joins(:candidate).merge(Candidate.for_transaction_emails)
        .joins(:application_choices).where('application_choices.declined_by_default': true)
        .distinct
    end
  end

  class SendDeclineByDefaultExplainerEmailToCandidatesBatchWorker < ApplicationJob
    def perform(application_form_ids)
      ApplicationForm.where(id: application_form_ids).includes(:application_choices).find_each do |application_form|
        CandidateMailer.decline_by_default_explainer(application_form).deliver_later
      end
    end
  end
end
