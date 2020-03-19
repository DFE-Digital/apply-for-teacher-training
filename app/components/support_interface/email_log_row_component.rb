module SupportInterface
  class EmailLogRowComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :email

    def initialize(email:)
      @email = email
    end

    def status_tag
      tag.span(email.delivery_status.humanize, class: "govuk-tag #{email.delivered? ? nil : 'govuk-tag--red'}")
    end

    def application_link
      return unless email.application_form

      govuk_link_to("#{email.application_form.full_name} (#{email.application_form.support_reference})", support_interface_application_form_path(email.application_form))
    end
  end
end
