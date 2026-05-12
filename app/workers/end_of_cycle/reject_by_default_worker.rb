module EndOfCycle
  class RejectByDefaultWorker
    include Sidekiq::Worker

    BATCH_SIZE = 120
    STAGGER_OVER = 1.hour

    def perform(force = false)
      return unless run_reject_by_default? || force

      BatchDelivery.new(relation:, stagger_over: STAGGER_OVER, batch_size: BATCH_SIZE).each do |batch_time, applications|
        RejectByDefaultSecondaryWorker.perform_at(batch_time, applications.pluck(:id))
      end
    end

    def relation
      if winter_rejection_by_default_set?
        application_form_ids = ApplicationChoice.course_start_in_september(RecruitmentCycleTimetable.current_year)
                                                .where(status: EndOfCycle::RejectByDefaultService::REJECTABLE_STATUSES)
                                                .pluck(:application_form_id).uniq
        ApplicationForm.where(id: application_form_ids)
      else
        ApplicationForm
          .current_cycle
          .joins(:application_choices).where('application_choices.status': EndOfCycle::RejectByDefaultService::REJECTABLE_STATUSES)
          .distinct
      end
    end

  private

    def run_reject_by_default?
      @run_reject_by_default ||= EndOfCycle::JobTimetabler.new.run_reject_by_default?
    end

    def winter_rejection_by_default_set?
      @winter_rejection_by_default_set ||= EndOfCycle::WinterJobTimetabler.new.winter_rejection_by_default_set?
    end

    def winter_rejection_by_default_set?
      @winter_rejection_by_default_set ||= EndOfCycle::JobTimetabler.new.winter_rejection_by_default_set?
    end
  end

  class RejectByDefaultSecondaryWorker
    include Sidekiq::Worker

    def perform(application_form_ids)
      application_forms = ApplicationForm.where(id: application_form_ids).includes(:application_choices)
      application_forms.find_each do |application_form|
        RejectByDefaultService.new(application_form).call
      end
    end
  end
end
