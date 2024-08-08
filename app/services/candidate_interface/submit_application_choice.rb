module CandidateInterface
  class SubmitApplicationChoice
    attr_reader :application_choice, :application_form, :inactive_date_calculator
    delegate :inactive_date, :inactive_days, to: :inactive_date_calculator

    def initialize(application_choice, inactive_date_calculator: InactiveDateCalculator)
      @application_choice = application_choice
      @application_form = application_choice.application_form
      @inactive_date_calculator = inactive_date_calculator.new(application_choice:, effective_date:)
    end

    def call
      raise ApplicationNotReadyToSendError, application_choice unless application_choice.unsubmitted?

      ActiveRecord::Base.transaction do
        application_choice.assign_attributes(personal_statement: application_form.becoming_a_teacher)
        application_form.update!(submitted_at:) unless application_form.submitted_applications?
        application_choice.update!(sent_to_provider_at:)
        application_choice.update!(reject_by_default_at: inactive_date, reject_by_default_days: inactive_days)
        ApplicationStateChange.new(application_choice).send_to_provider!

        SendNewApplicationEmailToProvider.new(application_choice:).call
        CandidateMailer.application_choice_submitted(application_choice).deliver_later
      end
    end

    def current_time
      Time.zone.now
    end
    alias effective_date current_time
    alias submitted_at current_time
    alias sent_to_provider_at current_time
  end
end
