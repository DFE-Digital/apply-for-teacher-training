module EndOfCycle
  class RejectByDefaultWorker
    include Sidekiq::Worker

    BATCH_SIZE = 120
    STAGGER_OVER = 1.hour

    def perform(force = false)
      return unless EndOfCycle::JobTimetabler.new.run_reject_by_default? || !run_winter_reject_by_default?.nil? || force

      BatchDelivery.new(relation:, stagger_over: STAGGER_OVER, batch_size: BATCH_SIZE).each do |batch_time, applications|
        RejectByDefaultSecondaryWorker.perform_at(batch_time, applications.pluck(:id))
      end
    end

    def relation
      cycle_application_forms
        .joins(:application_choices).where('application_choices.status': EndOfCycle::RejectByDefaultService::REJECTABLE_STATUSES)
        .distinct
    end

  private

    def cycle_application_forms
      if run_winter_reject_by_default?.nil?
        ApplicationForm.current_cycle
      elsif run_reject_by_default?
        application_form_ids = ApplicationChoice.course_start_in_september(RecruitmentCycleTimetable.current_year)
                                                .pluck(:application_form_id).uniq
        ApplicationForm.where(id: application_form_ids)
      elsif run_winter_reject_by_default?
        application_form_ids = ApplicationChoice.course_starts_after_september(RecruitmentCycleTimetable.previous_year)
                                                .pluck(:application_form_id).uniq
        ApplicationForm.where(id: application_form_ids)
      else
        ApplicationForm.none
      end
    end

    def run_reject_by_default?
      @run_reject_by_default ||= EndOfCycle::JobTimetabler.new.run_reject_by_default?
    end

    def run_winter_reject_by_default?
      @run_winter_reject_by_default ||= EndOfCycle::JobTimetabler.new.run_winter_reject_by_default?
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
