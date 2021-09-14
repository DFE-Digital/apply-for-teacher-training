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
        candidate_id_row,
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
        value: govuk_mail_to(email_address, email_address),
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
      return if right_to_work_or_study_blank?

      {
        key: 'Has the right to work or study in the UK?',
        value: right_to_work_or_study_value,
      }
    end

    def right_to_work_or_study_blank?
      if application_form.restructured_immigration_status?
        application_form.immigration_right_to_work?.nil?
      else
        application_form.right_to_work_or_study.blank?
      end
    end

    def right_to_work_or_study_value
      if application_form.restructured_immigration_status?
        application_form.immigration_right_to_work? ? 'Yes' : 'Not yet'
      else
        RIGHT_TO_WORK_OR_STUDY_DISPLAY_VALUES.fetch(application_form.right_to_work_or_study)
      end
    end

    def residency_details_row
      return unless residency_details_blank?

      {
        key: 'Residency details',
        value: residency_details_value,
      }
    end

    def residency_details_blank?
      if application_form.restructured_immigration_status?
        application_form.immigration_right_to_work?
      else
        application_form.right_to_work_or_study == 'yes'
      end
    end

    def residency_details_value
      if application_form.restructured_immigration_status?
        if application_form.immigration_status == 'other'
          application_form.immigration_status_details
        else
          I18n.t("application_form.personal_details.immigration_status.values.#{application_form.immigration_status}")
        end
      else
        application_form.right_to_work_or_study_details
      end
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

    def candidate_id_row
      {
        key: 'Candidate ID',
        value: candidate.public_id,
      }
    end

    attr_reader :application_form
  end
end
