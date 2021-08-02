module CandidateInterface
  class PersonalDetailsReviewPresenter
    include ActionView::Helpers::TagHelper
    include Rails.application.routes.url_helpers

    def initialize(personal_details_form:, nationalities_form:, languages_form:, right_to_work_form:, application_form:, editable: true, return_to_application_review: false)
      @personal_details_form = personal_details_form
      @nationalities_form = nationalities_form
      @languages_form = languages_form
      @right_to_work_or_study_form = right_to_work_form
      @application_form = application_form
      @editable = editable
      @return_to_application_review = return_to_application_review
    end

    def rows
      assembled_rows = [
        name_row,
        date_of_birth_row,
        nationality_row,
      ]

      assembled_rows << right_to_work_row

      unless LanguagesSectionPolicy.hide?(@application_form)
        assembled_rows << english_main_language_row
        assembled_rows << language_details_row
      end

      assembled_rows.compact
    end

  private

    def name_row
      {
        key: I18n.t('application_form.personal_details.name.label'),
        value: @personal_details_form.name,
        action: ('name' if @editable),
        change_path: candidate_interface_edit_name_and_dob_path(return_to_params),
        data_qa: 'personal-details-name',
      }
    end

    def date_of_birth_row
      {
        key: I18n.t('application_form.personal_details.date_of_birth.label'),
        value: @personal_details_form.date_of_birth.to_s(:govuk_date),
        action: ('date of birth' if @editable),
        change_path: candidate_interface_edit_name_and_dob_path(return_to_params),
        data_qa: 'personal-details-dob',
      }
    end

    def nationality_row
      {
        key: I18n.t('application_form.personal_details.nationality.label'),
        value: formatted_nationalities,
        action: ('nationality' if @editable),
        change_path: candidate_interface_edit_nationalities_path(return_to_params),
        data_qa: 'personal-details-nationality',
      }
    end

    def english_main_language_row
      {
        key: I18n.t('application_form.personal_details.english_main_language.label'),
        value: @languages_form.english_main_language&.titleize,
        action: ('if English is your main language' if @editable),
        change_path: candidate_interface_edit_languages_path(return_to_params),
        data_qa: 'personal-details-english-main-language',
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
        change_path: candidate_interface_edit_languages_path(return_to_params),
        data_qa: 'personal-details-other-language',
      }
    end

    def english_language_details_row
      {
        key: I18n.t('application_form.personal_details.english_language_details.label'),
        value: @languages_form.english_language_details,
        action: ('English language qualifications' if @editable),
        change_path: candidate_interface_edit_languages_path(return_to_params),
        data_qa: 'personal-details-english-details',
      }
    end

    def right_to_work_row
      return nil if british_or_irish?

      {
        key: 'Immigration status',
        value: formatted_right_to_work_or_study,
        action: ('Right to work or study' if @editable),
        change_path: candidate_interface_edit_right_to_work_or_study_path(return_to_params),
        data_qa: 'personal_details_right_to_work_or_study',
      }
    end

    def british_or_irish?
      @application_form.build_nationalities_hash[:irish] || @application_form.build_nationalities_hash[:british]
    end

    def formatted_nationalities
      [
        @nationalities_form.british,
        @nationalities_form.irish,
        @nationalities_form.other_nationality1,
        @nationalities_form.other_nationality2,
        @nationalities_form.other_nationality3,
      ]
      .reject(&:blank?)
      .to_sentence
    end

    def formatted_right_to_work_or_study
      case @right_to_work_or_study_form.right_to_work_or_study
      when 'yes'
        "I have the right to work or study in the UK<br> #{tag.p(@right_to_work_or_study_form.right_to_work_or_study_details)}".html_safe
      when 'no'
        'I will need to apply for permission to work or study in the UK'
      else
        'I do not know'
      end
    end

    def return_to_params
      { 'return-to' => 'application-review' } if @return_to_application_review
    end
  end
end
