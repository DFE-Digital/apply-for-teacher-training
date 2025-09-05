module ProviderInterface
  class PersonalInformationComponent < ApplicationComponent
    MISSING = '<em>Not provided</em>'.html_safe
    RIGHT_TO_WORK_OR_STUDY_DISPLAY_VALUES = {
      'yes' => 'Yes',
      'no' => 'Not yet',
      'decide_later' => 'Candidate does not know',
    }.freeze

    include ViewHelper

    delegate :first_name,
             :last_name,
             :candidate,
             to: :application_form

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
        candidate_id_number,
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
        value: FormatResidencyDetailsService.new(application_form:).residency_details_value,
      }
    end

    def candidate_id_number
      {
        key: 'Candidate number',
        value: application_form.candidate_id,
      }
    end

    def date_of_birth_row
      {
        key: 'Date of birth',
        value: application_form.date_of_birth ? application_form.date_of_birth.to_fs(:govuk_date) : MISSING,
      }
    end

    attr_reader :application_form
  end
end
