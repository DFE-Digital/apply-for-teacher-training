module CandidateInterface
  class PersonalDetailsReviewPresenter
    include ActionView::Helpers::TagHelper

    def initialize(personal_details_form:, nationalities_form:, languages_form:, right_to_work_form:, editable: true)
      @personal_details_form = personal_details_form
      @nationalities_form = nationalities_form
      @languages_form = languages_form
      @right_to_work_form = right_to_work_form
      @editable = editable
    end

    def rows
      if FeatureFlag.active?('international_personal_details')
        [
          name_row,
          date_of_birth_row,
          nationality_row,
          right_to_work_row,
        ]
        .compact
      else
        [
          name_row,
          date_of_birth_row,
          nationality_row,
          english_main_language_row,
          language_details_row,
        ]
          .compact
      end
    end

  private

    def name_row
      {
        key: I18n.t('application_form.personal_details.name.label'),
        value: @personal_details_form.name,
        action: ('name' if @editable),
        change_path: Rails.application.routes.url_helpers.candidate_interface_personal_details_edit_path,
      }
    end

    def date_of_birth_row
      {
        key: I18n.t('application_form.personal_details.date_of_birth.label'),
        value: @personal_details_form.date_of_birth.to_s(:govuk_date),
        action: ('date of birth' if @editable),
        change_path: Rails.application.routes.url_helpers.candidate_interface_personal_details_edit_path,
      }
    end

    def nationality_row
      {
        key: I18n.t('application_form.personal_details.nationality.label'),
        value: formatted_nationalities,
        action: ('nationality' if @editable),
        change_path: Rails.application.routes.url_helpers.candidate_interface_edit_nationalities_path,
      }
    end

    def english_main_language_row
      {
        key: I18n.t('application_form.personal_details.english_main_language.label'),
        value: @languages_form.english_main_language.titleize,
        action: ('if English is your main language' if @editable),
        change_path: Rails.application.routes.url_helpers.candidate_interface_languages_path,
      }
    end

    def language_details_row
      if @languages_form.english_main_language?
        other_language_details_row if @languages_form.other_language_details.present?
      elsif @languages_form.english_language_details.present?
        english_language_details_row
      end
    end

    def other_language_details_row
      {
        key: I18n.t('application_form.personal_details.other_language_details.label'),
        value: @languages_form.other_language_details,
        action: ('other languages' if @editable),
        change_path: Rails.application.routes.url_helpers.candidate_interface_languages_path,
      }
    end

    def english_language_details_row
      {
        key: I18n.t('application_form.personal_details.english_language_details.label'),
        value: @languages_form.english_language_details,
        action: ('English language qualifications' if @editable),
        change_path: Rails.application.routes.url_helpers.candidate_interface_languages_path,
      }
    end

    def right_to_work_row
      if @nationalities_form.first_nationality != 'British' && @nationalities_form.first_nationality != 'Irish'
        {
          key: 'Residency status',
          value: "#{formatted_right_to_work_or_study} <br> #{tag.p(@right_to_work_form.right_to_work_or_study_details)}".html_safe,
          action: ('Right to work or study' if @editable),
          change_path: Rails.application.routes.url_helpers.candidate_interface_edit_right_to_work_or_study_path,
        }
      end
    end

    def formatted_nationalities
      if @nationalities_form.multiple_nationalities.present?
        @nationalities_form.multiple_nationalities
      elsif FeatureFlag.active?('international_personal_details')
        @nationalities_form.first_nationality
      else
        [
          @nationalities_form.first_nationality,
          @nationalities_form.second_nationality,
        ]
        .reject(&:blank?)
        .to_sentence
      end
    end

    def formatted_right_to_work_or_study
      case @right_to_work_form.right_to_work_or_study
      when 'Yes – I have the right to work or study in the UK'
        'I have the right to work or study in the UK'
      when 'Not yet – I will need to apply for permission to work or study in the UK'
        'I will need to apply for permission to work or study in the UK'
      else
        'I do not know'
      end
    end
  end
end
