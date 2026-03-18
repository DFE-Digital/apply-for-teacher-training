module ProviderInterface
  class ContactInformationComponent < ApplicationComponent
    MISSING = '<em>Not provided</em>'.html_safe

    delegate :phone_number,
             :candidate,
             to: :application_form

    delegate :email_address, to: :candidate

    def initialize(application_form:)
      @application_form = application_form
    end

    def rows
      [
        phone_number_row,
        email_row,
        address_row,
      ].compact
    end

  private

    def email_row
      {
        key: 'Email address',
        value: govuk_mail_to(email_address, email_address),
      }
    end

    def phone_number_row
      {
        key: 'Phone number',
        value: phone_number || MISSING,
      }
    end

    def address_row
      {
        key: 'Address',
        value: application_form.full_address,
      }
    end

    attr_reader :application_form
  end
end
