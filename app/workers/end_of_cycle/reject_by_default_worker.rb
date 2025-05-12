module EndOfCycle
  class RejectByDefaultWorker
    include Sidekiq::Worker

    BATCH_SIZE = 120

    def perform(force = false)
      return unless EndOfCycle::JobTimetabler.new.run_reject_by_default? || force

      BatchDelivery.new(relation:, batch_size: BATCH_SIZE).each do |batch_time, applications|
        RejectByDefaultSecondaryWorker.perform_at(batch_time, applications.pluck(:id))
      end
    end

    def relation
      ApplicationForm
        .current_cycle
        .joins(:application_choices).where('application_choices.status': EndOfCycle::RejectByDefaultService::REJECTABLE_STATUSES)
        .distinct
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
