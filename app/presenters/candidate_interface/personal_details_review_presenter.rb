module CandidateInterface
  class PersonalDetailsReviewPresenter
    def initialize(personal_details_form:, nationalities_form:, languages_form:, editable: true)
      @personal_details_form = personal_details_form
      @nationalities_form = nationalities_form
      @languages_form = languages_form
      @editable = editable
    end

    def rows
      [
        name_row,
        date_of_birth_row,
        nationality_row,
        english_main_language_row,
        language_details_row,
      ]
        .compact
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
        change_path: Rails.application.routes.url_helpers.candidate_interface_nationalities_path,
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

    def formatted_nationalities
      [
        @nationalities_form.first_nationality,
        @nationalities_form.second_nationality,
      ]
        .reject(&:blank?)
        .to_sentence
    end
  end
end
