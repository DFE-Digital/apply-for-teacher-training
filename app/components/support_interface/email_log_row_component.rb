module SupportInterface
  class EmailLogRowComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :email

    def initialize(email:)
      @email = email
    end

    def status_tag
      colour_tag = {
        not_tracked: 'govuk-tag--grey',
        pending: 'govuk-tag--pink',
        unknown: 'govuk-tag--grey',
        delivered: 'govuk-tag--green',
        permanent_failure: 'govuk-tag--red',
        temporary_failure: 'govuk-tag--yellow',
        technical_failure: 'govuk-tag--orange',
      }[email.delivery_status.to_sym]

      tag.span(email.delivery_status.humanize, class: "govuk-tag #{colour_tag}")
    end

    def application_link
      return unless email.application_form

      govuk_link_to("#{email.application_form.full_name} (#{email.application_form.support_reference})", support_interface_application_form_path(email.application_form))
    end
  end
end
