module CandidateInterface
  class PersonalDetailsReviewPresenter
    def initialize(form:, editable: true)
      @form = form
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
        .map { |row| add_change_path(row) }
    end

  private

    def name_row
      {
        key: I18n.t('application_form.personal_details.name.label'),
        value: @form.name,
        action: ('name' if @editable),
      }
    end

    def date_of_birth_row
      {
        key: I18n.t('application_form.personal_details.date_of_birth.label'),
        value: @form.date_of_birth.strftime('%e %B %Y'),
        action: ('date of birth' if @editable),
      }
    end

    def nationality_row
      {
        key: I18n.t('application_form.personal_details.nationality.label'),
        value: formatted_nationalities,
        action: ('nationality' if @editable),
      }
    end

    def english_main_language_row
      {
        key: I18n.t('application_form.personal_details.english_main_language.label'),
        value: @form.english_main_language.titleize,
        action: ('if English is your main language' if @editable),
      }
    end

    def language_details_row
      if @form.english_main_language?
        english_main_language_details_row if @form.other_language_details.present?
      elsif @form.english_language_details.present?
        other_language_details_row
      end
    end

    def english_main_language_details_row
      {
        key: I18n.t('application_form.personal_details.english_main_language_details.label'),
        value: @form.other_language_details,
        action: ('other languages' if @editable),
      }
    end

    def other_language_details_row
      {
        key: I18n.t('application_form.personal_details.other_language_details.label'),
        value: @form.english_language_details,
        action: ('english languages qualifications' if @editable),
      }
    end

    def formatted_nationalities
      [
        @form.first_nationality,
        @form.second_nationality,
      ]
        .reject(&:blank?)
        .to_sentence
    end

    def add_change_path(row)
      edit_path = Rails.application.routes.url_helpers.candidate_interface_personal_details_edit_path
      row[:change_path] = edit_path if @editable
      row
    end
  end
end
