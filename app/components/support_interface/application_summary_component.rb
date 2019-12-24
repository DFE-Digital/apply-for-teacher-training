module SupportInterface
  class ApplicationSummaryComponent < ActionView::Component::Base
    include ViewHelper

    delegate :support_reference,
             :submitted_at,
             :submitted?,
             :updated_at,
             to: :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def rows
      [
        support_reference_row,
        submitted_row,
        last_updated_row,
        state_row,
      ].compact
    end

  private

    def last_updated_row
      {
        key: 'Last updated',
        value: "#{updated_at.to_s(:govuk_date_and_time)} (#{govuk_link_to('History', support_interface_application_form_audit_path(application_form))})".html_safe,
      }
    end

    def submitted_row
      if submitted?
        {
          key: 'Submitted',
          value: submitted_at.to_s(:govuk_date_and_time),
        }
      end
    end

    def support_reference_row
      if support_reference
        {
          key: 'Support reference',
          value: support_reference,
        }
      end
    end

    def state_row
      {
        key: 'State',
        value: formatted_status,
      }
    end

    def formatted_status
      process_state = ProcessState.new(application_form).state
      name = I18n.t!("process_states.#{process_state}.name")
      desc = I18n.t!("process_states.#{process_state}.description")
      "#{name} – #{desc}"
    end

    attr_reader :application_form
  end
end
