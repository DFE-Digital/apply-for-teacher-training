module SupportInterface
  class ApplicationsTableComponent < ActionView::Component::Base
    include ViewHelper

    def initialize(application_forms:)
      @application_forms = application_forms
    end

    def table_rows
      application_forms.map do |application_form|
        submitted = application_form.submitted?
        email_address = application_form.candidate.email_address

        {
          application_form_id: application_form.id,
          application_link: govuk_link_to(email_address, support_interface_application_form_path(application_form)),
          first_reference_status: reference_status(application_form.references[0], submitted),
          second_reference_status: reference_status(application_form.references[1], submitted),
          updated_at: application_form.updated_at.strftime('%e %b %Y at %l:%M%P'),
        }
      end
    end

  private

    attr_reader :application_forms

    def reference_status(reference, submitted)
      return 'Not requested yet' unless reference && submitted

      reference.complete? ? 'Received' : 'Awaiting response'
    end
  end
end
