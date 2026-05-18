module EndOfCycle
  class SendWinterRejectByDefaultExplainerEmailToCandidatesWorker
    include Sidekiq::Worker

    BATCH_SIZE = 120

    def perform
      return unless send_emails?

      BatchDelivery.new(relation:, batch_size: BATCH_SIZE).each do |batch_time, application_forms|
        SendWinterRejectByDefaultExplainerEmailToCandidatesBatchWorker.perform_at(batch_time, application_forms.pluck(:id))
      end
    end

    def relation
      ids = ApplicationChoice.course_starts_after_september(RecruitmentCycleTimetable.previous_year)
              .where(rejected_by_default: true)
              .pluck(:application_form_id).uniq
      ApplicationForm
        .previous_cycle
        .joins(:candidate).merge(Candidate.for_transaction_emails)
        .where(id: ids)
        .distinct
    end

  private

    def send_emails?
      CandidateEmailTimetabler.new.send_winter_reject_by_default_explainer?
    end
  end

  class SendWinterRejectByDefaultExplainerEmailToCandidatesBatchWorker
    include Sidekiq::Worker

    def perform(application_form_ids)
      ApplicationForm.where(id: application_form_ids).includes(:application_choices).find_each do |application_form|
        if application_form.application_choices.pluck(:status).include?('offer')
          CandidateMailer.respond_to_offer_before_winter_deadline(application_form).deliver_later
        else
          CandidateMailer.winter_reject_by_default_explainer(application_form).deliver_later
        end
      end
    end
  end
end
