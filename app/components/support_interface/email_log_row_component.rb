module SupportInterface
  class EmailLogRowComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :email

    def initialize(email:)
      @email = email
    end

    def summary_list_rows
      rows = [
        { key: 'Status', value: status_tag },
        { key: 'Type', value: email.humanised_email_type },
        { key: 'To', value: email.to },
        { key: 'Subject', value: email.subject.inspect },
      ]

      if email.application_form
        rows << { key: 'Application', value: application_link }
      end

      rows
    end

  private

    def status_tag
      colour = {
        not_tracked: 'grey',
        pending: 'yellow',
        unknown: 'grey',
        delivered: 'green',
        notify_error: 'red',
        permanent_failure: 'red',
        temporary_failure: 'pink',
        technical_failure: 'orange',
      }[email.delivery_status.to_sym]

      govuk_tag(
        text: email.delivery_status.humanize,
        colour: colour,
        html_attributes: {
          title: "Notify reference: `#{email.notify_reference}`",
        },
      )
    end

    def application_link
      govuk_link_to("#{email.application_form.full_name} (#{email.application_form.support_reference})", support_interface_application_form_path(email.application_form))
    end
  end
end
