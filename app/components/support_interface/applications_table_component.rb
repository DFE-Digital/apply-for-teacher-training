module SupportInterface
  class ApplicationsTableComponent < ActionView::Component::Base
    include ViewHelper

    def initialize(application_forms:)
      @application_forms = application_forms
    end

    def table_rows
      application_forms.map do |application_form|
        email_address = application_form.candidate.email_address

        {
          application_form_id: application_form.id,
          application_link: govuk_link_to(email_address, support_interface_application_form_path(application_form)),
          updated_at: application_form.updated_at.to_s(:govuk_date_and_time),
          process_state: ProcessState.new(application_form).state,
          support_reference: application_form.support_reference,
        }
      end
    end

  private

    attr_reader :application_forms
  end
end
