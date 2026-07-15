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
             :previous_last_names,
             :candidate,
             to: :application_form

    def initialize(application_form:, application_choice:)
      @application_form = application_form
      @application_choice = application_choice
    end

    def rows
      [
        first_name_row,
        last_name_row,
        previous_last_names_row,
        date_of_birth_row,
        nationality_row,
        right_to_work_or_study_row,
        visa_status_row,
        visa_expiry_row,
        visa_explanation_row,
        residency_row,
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

    def previous_last_names_row
      return if previous_last_names.blank?

      {
        key: 'Previous last names',
        value: previous_last_names,
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

    def visa_status_row
      return unless application_form.right_to_work_or_study == 'yes'

      {
        key: 'Visa type or immigration status',
        value: FormatResidencyDetailsService.new(application_form:).residency_details_value,
      }
    end

    def candidate_id_number
      {
        key: 'Candidate number',
        value: application_form.candidate_id,
      }
    end

    def visa_expiry_row
      if @application_form.temporary_immigration_status? &&
         @application_form.visa_expired_at.present?

        {
          key: t('page_titles.visa_expiry'),
          value: @application_form.visa_expired_at.to_fs(:govuk_date),
        }
      end
    end

    def visa_explanation_row
      if @application_form.temporary_immigration_status? &&
         @application_choice&.visa_explanation.present? &&
         @application_choice&.visa_expires_soon?

        {
          key: 'Visa status',
          value: render(VisaExplanationComponent.new(@application_choice)),
        }
      end
    end

    def residency_row
      return if @application_form.country_residency_date_from.blank?

      {
        key: "Lived in #{CountryFinder.find_name_from_hesa_code(@application_form.country)} since",
        value: @application_form.country_residency_since_birth ? 'Birth' : @application_form.country_residency_date_from.to_fs(:month_and_year),
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
