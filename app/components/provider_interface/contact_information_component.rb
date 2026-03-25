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
        residency_row,
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

    def residency_row
      return unless FeatureFlag.active?('2027_application_form_contact_details_residency_questions')
      return if @application_form.country_residency_date_from.blank?

      {
        key: "Lived in #{CountryFinder.find_name_from_hesa_code(@application_form.country)} since",
        value: @application_form.country_residency_since_birth ? 'Birth' : @application_form.country_residency_date_from.to_fs(:month_and_year),
      }
    end

    attr_reader :application_form
  end
end
