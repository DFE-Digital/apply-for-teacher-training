module EndOfCycle
  class WinterDeclineByDefaultWorker < ApplicationJob
    BATCH_SIZE = 120
    STAGGER_OVER = 1.minute

    def perform(force = false)
      return unless run_winter_decline_by_default? || force

      BatchDelivery.new(relation:, stagger_over: STAGGER_OVER, batch_size: BATCH_SIZE).each do |batch_time, applications|
        WinterDeclineByDefaultSecondaryWorker.set(wait_until: batch_time).perform_later(applications.pluck(:id))
      end
    end

    def relation
      application_form_ids = ApplicationChoice.course_starts_after_september(RecruitmentCycleTimetable.previous_year)
                                              .where(status: 'offer')
                                              .pluck(:application_form_id).uniq
      ApplicationForm.where(id: application_form_ids)
    end

  private

    def run_winter_decline_by_default?
      @run_winter_decline_by_default ||= EndOfCycle::WinterJobTimetabler.new.run_winter_decline_by_default?
    end
  end

  class WinterDeclineByDefaultSecondaryWorker < ApplicationJob
    def perform(application_form_ids)
      application_forms = ApplicationForm.where(id: application_form_ids).includes(:application_choices)
      application_forms.find_each do |application_form|
        DeclineByDefaultService.new(application_form).call
      end
    end
  end
end
