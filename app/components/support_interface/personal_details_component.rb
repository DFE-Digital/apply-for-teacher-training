module SupportInterface
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
        domicile_row,
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
        action: 'first name',
        change_path: support_interface_application_form_edit_applicant_details_path(application_form),
      }
    end

    def last_name_row
      {
        key: 'Last name',
        value: last_name,
        action: 'last name',
        change_path: support_interface_application_form_edit_applicant_details_path(application_form),
      }
    end

    def email_row
      {
        key: 'Email address',
        value: govuk_mail_to(email_address, email_address),
        action: 'email address',
        change_path: support_interface_application_form_edit_applicant_details_path(application_form),
      }
    end

    def phone_number_row
      {
        key: 'Phone number',
        value: phone_number || MISSING,
        action: 'phone number',
        change_path: support_interface_application_form_edit_applicant_details_path(application_form),
      }
    end

    def nationality_row
      {
        key: 'Nationality',
        value: application_form.nationalities.to_sentence(last_word_connector: ' and '),
        action: 'nationality',
        change_path: support_interface_application_form_edit_nationalities_path(application_form),
      }
    end

    def domicile_row
      {
        key: 'Domicile',
        value: application_form.domicile,
      }
    end

    def right_to_work_or_study_row
      return if application_form.right_to_work_or_study.blank?

      {
        key: 'Has the right to work or study in the UK?',
        value: RIGHT_TO_WORK_OR_STUDY_DISPLAY_VALUES.fetch(application_form.right_to_work_or_study),
        action: 'right to work or study',
        change_path: support_interface_application_form_edit_right_to_work_or_study_path(application_form),
      }
    end

    def residency_details_row
      return unless application_form.right_to_work_or_study == 'yes'

      {
        key: 'Residency details',
        value: application_form.right_to_work_or_study_details,
        action: 'residency details',
        change_path: support_interface_application_form_edit_right_to_work_or_study_path(application_form),
      }
    end

    def date_of_birth_row
      {
        key: 'Date of birth',
        value: application_form.date_of_birth ? application_form.date_of_birth.to_s(:govuk_date) : MISSING,
        action: 'date of birth',
        change_path: support_interface_application_form_edit_applicant_details_path(application_form),
      }
    end

    def address_row
      {
        key: 'Address',
        value: full_address,
        action: 'address',
        change_path: support_interface_application_form_edit_address_type_path(application_form),
      }
    end

    def full_address
      if @application_form.address_type == 'uk'
        local_address.reject(&:blank?)
      else
        local_address.concat([COUNTRIES[@application_form.country]]).reject(&:blank?)
      end
    end

    def local_address
      [
        @application_form.address_line1,
        @application_form.address_line2,
        @application_form.address_line3,
        @application_form.address_line4,
        @application_form.postcode,
      ]
    end

    attr_reader :application_form
  end
end
