module SupportInterface
  class ApplicationCardComponent < ViewComponent::Base
    include ViewHelper

    attr_accessor :application_form, :updated_at, :support_reference

    def initialize(application_form:)
      @application_form = application_form
      @support_reference = application_form.support_reference
      @updated_at = application_form.updated_at.to_s(:govuk_date_and_time)
    end

    def candidate_name
      application_form.full_name.presence || application_form.candidate.email_address
    end

    def overall_status
      process_state = ProcessState.new(application_form).state
      I18n.t!("candidate_flow_application_states.#{process_state}.name")
    end
  end
end
