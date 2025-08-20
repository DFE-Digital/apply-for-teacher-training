module SupportInterface
  class ApplicationCardComponent < ViewComponent::Base
    include ViewHelper

    attr_accessor :application_form, :updated_at, :support_reference

    def initialize(application_form:, heading_level: 2)
      @application_form = application_form
      @support_reference = application_form.support_reference
      @updated_at = application_form.updated_at.to_fs(:govuk_date_and_time)
      @heading_level = heading_level
    end

    def candidate_name
      application_form.full_name.presence || application_form.candidate.email_address
    end

    delegate :application_choices, to: :application_form

    def overall_status
      candidate_flow_state = ApplicationFormStateInferrer.new(application_form).state
      I18n.t!("candidate_flow_application_states.#{candidate_flow_state}.name")
    end

    def apply_again_context
      if application_form.candidate_has_previously_applied?
        "(#{application_form.recruitment_cycle_year}, carried over)"
      else
        "(#{application_form.recruitment_cycle_year})"
      end
    end
  end
end
