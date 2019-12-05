module SupportInterface
  class ApplicationSummaryComponent < ActionView::Component::Base
    include ViewHelper

    delegate :first_name,
             :last_name,
             :phone_number,
             :support_reference,
             :submitted_at,
             :submitted?,
             :updated_at,
             :candidate,
             to: :application_form

    delegate :email_address, to: :candidate

    def initialize(application_form:)
      @application_form = application_form
    end

    def rows
      [
        name_row,
        support_reference_row,
        email_row,
        phone_number_row,
        submitted_row,
        last_updated_row,
        state_row,
      ].compact
    end

  private

    def name_row
      if first_name
        {
          key: 'Name',
          value: "#{first_name} #{last_name}",
        }
      end
    end

    def email_row
      {
        key: 'Email address',
        value: mail_to(email_address, email_address, class: 'govuk-link'),
      }
    end

    def phone_number_row
      if phone_number
        {
          key: 'Phone number',
          value: phone_number,
        }
      end
    end

    def last_updated_row
      {
        key: 'Last updated',
        value: "#{updated_at.strftime('%e %b %Y at %l:%M%P')} (#{govuk_link_to('History', support_interface_application_form_audit_path(application_form))})".html_safe,
      }
    end

    def submitted_row
      if submitted?
        {
          key: 'Submitted',
          value: submitted_at.strftime('%e %b %Y at %l:%M%P'),
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
      "#{name} - #{desc}"
    end

    def application_choices
      application_form.application_choices.includes(:course, :provider)
    end

    attr_reader :application_form
  end
end
