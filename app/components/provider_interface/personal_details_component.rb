module ProviderInterface
  class PersonalDetailsComponent < ViewComponent::Base
    MISSING = '<em>Not provided</em>'.html_safe
    RIGHT_TO_WORK_OR_STUDY_DISPLAY_VALUES = {
      'yes' => 'Yes',
      'no' => 'Not yet',
      'decide_later' => 'Candidate does not know',
    }.freeze

    include ViewHelper

    delegate :first_name,
             :last_name,
             :phone_number,
             :candidate,
             to: :application_form

    delegate :email_address, to: :candidate

    def initialize(application_form:)
      @application_form = application_form
    end

    def rows
      [
        first_name_row,
        last_name_row,
        date_of_birth_row,
        nationality_row,
        right_to_work_or_study_row,
        residency_details_row,
        phone_number_row,
        email_row,
        address_row,
      ].compact
    end

  private

    def first_name_row
      {
        key: 'First name',
        value: first_name,
      }
    end

    def last_name_row
      {
        key: 'Last name',
        value: last_name,
      }
    end

    def email_row
      {
        key: 'Email address',
        value: mail_to(email_address, email_address, class: 'govuk-link'),
      }
    end

    def phone_number_row
      {
        key: 'Phone number',
        value: phone_number || MISSING,
      }
    end

    def nationality_row
      {
        key: 'Nationality',
        value: application_form.nationalities.to_sentence(last_word_connector: ' and '),
      }
    end

    def right_to_work_or_study_row
      return if application_form.right_to_work_or_study.blank?

      {
        key: 'Has the right to work or study in the UK?',
        value: RIGHT_TO_WORK_OR_STUDY_DISPLAY_VALUES.fetch(application_form.right_to_work_or_study),
      }
    end

    def residency_details_row
      return unless application_form.right_to_work_or_study == 'yes'

      {
        key: 'Residency details',
        value: application_form.right_to_work_or_study_details,
      }
    end

    def date_of_birth_row
      {
        key: 'Date of birth',
        value: application_form.date_of_birth ? application_form.date_of_birth.to_s(:govuk_date) : MISSING,
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
