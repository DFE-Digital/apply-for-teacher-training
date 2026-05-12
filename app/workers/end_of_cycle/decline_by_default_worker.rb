module EndOfCycle
  class DeclineByDefaultWorker
    include Sidekiq::Worker

    BATCH_SIZE = 120
    STAGGER_OVER = 1.minute

    def perform(force = false)
      return unless run_decline_by_default? || run_winter_decline_by_default? || force

      BatchDelivery.new(relation:, stagger_over: STAGGER_OVER, batch_size: BATCH_SIZE).each do |batch_time, applications|
        DeclineByDefaultSecondaryWorker.perform_at(batch_time, applications.pluck(:id))
      end
    end

    def relation
      cycle_application_forms
        .joins(:application_choices).where('application_choices.status': 'offer')
        .distinct
    end

  private

    def cycle_application_forms
      if !winter_decline_by_default_set?
        ApplicationForm.current_cycle
      elsif run_decline_by_default?
        application_form_ids = ApplicationChoice.course_start_in_september(RecruitmentCycleTimetable.current_year)
                                                .pluck(:application_form_id).uniq
        ApplicationForm.where(id: application_form_ids)
      elsif run_winter_decline_by_default?
        application_form_ids = ApplicationChoice.course_starts_after_september(RecruitmentCycleTimetable.previous_year)
                                                .pluck(:application_form_id).uniq
        ApplicationForm.where(id: application_form_ids)
      else
        ApplicationForm.none
      end
    end

    def run_decline_by_default?
      @run_decline_by_default ||= EndOfCycle::JobTimetabler.new.run_decline_by_default?
    end

    def run_winter_decline_by_default?
      @run_winter_decline_by_default ||= EndOfCycle::JobTimetabler.new.run_winter_decline_by_default?
    end

    def winter_decline_by_default_set?
      @winter_decline_by_default_set ||= EndOfCycle::JobTimetabler.new.winter_decline_by_default_set?
    end
  end

  class DeclineByDefaultSecondaryWorker
    include Sidekiq::Worker

    def perform(application_form_ids)
      application_forms = ApplicationForm.where(id: application_form_ids).includes(:application_choices)
      application_forms.find_each do |application_form|
        DeclineByDefaultService.new(application_form).call
      end
    end
  end
end
