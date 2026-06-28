module EndOfCycle
  class DeclineByDefaultWorker < ApplicationJob
    self.queue_adapter = :solid_queue

    BATCH_SIZE = 120
    STAGGER_OVER = 1.minute

    def perform(force = false)
      return unless run_decline_by_default? || force

      BatchDelivery.new(relation:, stagger_over: STAGGER_OVER, batch_size: BATCH_SIZE).each do |batch_time, applications|
        DeclineByDefaultSecondaryWorker.perform_at(batch_time, applications.pluck(:id))
      end
    end

    def relation
      if winter_decline_by_default_set?
        application_form_ids = ApplicationChoice.course_start_in_september(RecruitmentCycleTimetable.current_year)
                                                .where(status: 'offer')
                                                .pluck(:application_form_id).uniq
        ApplicationForm.where(id: application_form_ids)
      else
        ApplicationForm.current_cycle
                       .joins(:application_choices).where('application_choices.status': 'offer')
                       .distinct
      end
    end

  private

    def run_decline_by_default?
      @run_decline_by_default ||= EndOfCycle::JobTimetabler.new.run_decline_by_default?
    end

    def winter_decline_by_default_set?
      @winter_decline_by_default_set ||= EndOfCycle::WinterJobTimetabler.new.winter_decline_by_default_set?
    end
  end

  class DeclineByDefaultSecondaryWorker < ApplicationJob
    self.queue_adapter = :solid_queue

    def perform(application_form_ids)
      application_forms = ApplicationForm.where(id: application_form_ids).includes(:application_choices)
      application_forms.find_each do |application_form|
        DeclineByDefaultService.new(application_form).call
      end
    end
  end
end
