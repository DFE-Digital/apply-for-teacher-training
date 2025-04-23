module EndOfCycle
  class CancelUnsubmittedApplicationsWorker
    include Sidekiq::Worker

    BATCH_SIZE = 200

    def perform(force = false)
      return unless EndOfCycle::JobTimetabler.new.cancel_unsubmitted_applications? || force

      BatchDelivery.new(relation:, stagger_over: 2.hours, batch_size: BATCH_SIZE).each do |batch_time, applications|
        CancelUnsubmittedApplicationsSecondaryWorker.perform_at(batch_time, applications.pluck(:id))
      end
    end

    def relation
      ApplicationForm
        .current_cycle
        .joins(:application_choices).where('application_choices.status': 'unsubmitted')
        .distinct
    end
  end

  class CancelUnsubmittedApplicationsSecondaryWorker
    include Sidekiq::Worker

    def perform(application_form_ids)
      application_forms = ApplicationForm.where(id: application_form_ids).includes(:application_choices)
      application_forms.find_each do |application_form|
        application_form.application_choices.unsubmitted.each do |application_choice|
          ApplicationStateChange.new(application_choice).reject_at_end_of_cycle!
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.warn "Unable to cancel application #{application_choice.id}. Error: #{e}"
        end
      end
    end
  end
end
