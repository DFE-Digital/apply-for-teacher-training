module EndOfCycle
  class SendWinterDeclineByDefaultExplainerEmailToCandidatesWorker
    include Sidekiq::Worker

    BATCH_SIZE = 120

    def perform
      return unless send_emails?

      BatchDelivery.new(relation:, batch_size: BATCH_SIZE).each do |batch_time, application_forms|
        SendWinterDeclineByDefaultExplainerEmailToCandidatesBatchWorker.perform_at(batch_time, application_forms.pluck(:id))
      end
    end

    def relation
      ids = ApplicationChoice.course_starts_after_september(timetable.recruitment_cycle_year)
                             .where(declined_by_default: true)
                             .pluck(:application_form_id).uniq
      ApplicationForm
        .joins(:candidate).merge(Candidate.for_transaction_emails)
        .where(id: ids)
        .distinct
    end

  private

    def send_emails?
      CandidateEmailTimetabler.new(timetable:).send_winter_decline_by_default_explainer?
    end

    def timetable
      @timetable ||= RecruitmentCycleTimetable.previous_timetable
    end
  end

  class SendWinterDeclineByDefaultExplainerEmailToCandidatesBatchWorker
    include Sidekiq::Worker

    def perform(application_form_ids)
      ApplicationForm.where(id: application_form_ids).includes(:application_choices).find_each do |application_form|
        CandidateMailer.winter_decline_by_default_explainer(application_form).deliver_later
      end
    end
  end
end
