module EndOfCycle
  class SendRejectByDefaultExplainerEmailToCandidatesWorker
    include Sidekiq::Worker

    BATCH_SIZE = 120

    def perform
      return unless CandidateEmailTimetabler.new.send_reject_by_default_explainer?

      BatchDelivery.new(relation:, batch_size: BATCH_SIZE).each do |batch_time, application_forms|
        SendRejectByDefaultExplainerEmailToCandidatesBatchWorker.perform_at(batch_time, application_forms.pluck(:id))
      end
    end

    def relation
      ApplicationForm
        .current_cycle
        .joins(:candidate).merge(Candidate.for_transaction_emails)
        .joins(:application_choices).where('application_choices.rejected_by_default': true)
        .distinct
    end
  end

  class SendRejectByDefaultExplainerEmailToCandidatesBatchWorker
    include Sidekiq::Worker

    def perform(application_form_ids)
      ApplicationForm.where(id: application_form_ids).includes(:application_choices).find_each do |application_form|
        if application_form.application_choices.pluck(:status).include?('offer')
          CandidateMailer.respond_to_offer_before_deadline(application_form).deliver_later
        else
          CandidateMailer.reject_by_default_explainer(application_form).deliver_later
        end
      end
    end
  end
end
