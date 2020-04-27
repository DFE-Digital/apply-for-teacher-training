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
      colour_tag = {
        not_tracked: 'govuk-tag--grey',
        pending: 'govuk-tag--yellow',
        unknown: 'govuk-tag--grey',
        delivered: 'govuk-tag--green',
        notify_error: 'govuk-tag--red',
        permanent_failure: 'govuk-tag--red',
        temporary_failure: 'govuk-tag--pink',
        technical_failure: 'govuk-tag--orange',
      }[email.delivery_status.to_sym]

      tag.span(email.delivery_status.humanize, class: "govuk-tag #{colour_tag}", title: "Notify reference: `#{email.notify_reference}`")
    end

    def application_link
      govuk_link_to("#{email.application_form.full_name} (#{email.application_form.support_reference})", support_interface_application_form_path(email.application_form))
    end
  end
end
