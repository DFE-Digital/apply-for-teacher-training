module CandidateInterface
  class PersonalDetailsReviewPresenter
    def initialize(form)
      @form = form
    end

    def present
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
        action: 'name',
      }
    end

    def date_of_birth_row
      {
        key: I18n.t('application_form.personal_details.date_of_birth.label'),
        value: @form.date_of_birth.strftime('%e %B %Y'),
        action: 'date of birth',
      }
    end

    def nationality_row
      {
        key: I18n.t('application_form.personal_details.nationality.label'),
        value: formatted_nationalities,
        action: 'nationality',
      }
    end

    def english_main_language_row
      {
        key: I18n.t('application_form.personal_details.english_main_language.label'),
        value: @form.english_main_language.titleize,
        action: 'if English is your main language',
      }
    end

    def language_details_row
      if @form.english_main_language?
        english_main_language_details_row if @form.english_language_details.present?
      elsif @form.other_language_details.present?
        other_language_details_row
      end
    end

    def english_main_language_details_row
      {
        key: I18n.t('application_form.personal_details.english_main_language_details.label'),
        value: @form.english_language_details,
        action: 'other languages',
      }
    end

    def other_language_details_row
      {
        key: I18n.t('application_form.personal_details.other_language_details.label'),
        value: @form.other_language_details,
        action: 'english languages qualifications',
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
      row[:change_path] = Rails.application.routes.url_helpers.candidate_interface_personal_details_edit_path
      row
    end
  end
end
