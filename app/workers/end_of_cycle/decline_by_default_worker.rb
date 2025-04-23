module EndOfCycle
  class DeclineByDefaultWorker
    include Sidekiq::Worker

    BATCH_SIZE = 120
    STAGGER_OVER = 1.minute

    def perform(force = false)
      return unless EndOfCycle::JobTimetabler.new.run_decline_by_default? || force

      BatchDelivery.new(relation:, stagger_over: STAGGER_OVER, batch_size: BATCH_SIZE).each do |batch_time, applications|
        DeclineByDefaultSecondaryWorker.perform_at(batch_time, applications.pluck(:id))
      end
    end

    def relation
      ApplicationForm
        .current_cycle
        .joins(:application_choices).where('application_choices.status': 'offer')
        .distinct
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
