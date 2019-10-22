class PersonalDetailsReviewPresenter
  def initialize(application_form)
    @application_form = application_form
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
      value: @application_form.name,
      action: 'name',
    }
  end

  def date_of_birth_row
    return unless @application_form.date_of_birth

    {
      key: I18n.t('application_form.personal_details.date_of_birth.label'),
      value: @application_form.date_of_birth.strftime('%e %B %Y'),
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
      value: boolean_to_word(@application_form.english_main_language).titleize,
      action: 'if English is your main language',
    }
  end

  def language_details_row
    if @application_form.english_main_language?
      english_main_language_details_row if @application_form.english_language_details.present?
    elsif @application_form.other_language_details.present?
      other_language_details_row
    end
  end

  def english_main_language_details_row
    {
      key: I18n.t('application_form.personal_details.english_main_language_details.label'),
      value: @application_form.english_language_details,
      action: 'other languages',
    }
  end

  def other_language_details_row
    {
      key: I18n.t('application_form.personal_details.other_language_details.label'),
      value: @application_form.other_language_details,
      action: 'english languages qualifications',
    }
  end

  def formatted_nationalities
    [
      @application_form.first_nationality,
      @application_form.second_nationality,
    ]
      .reject(&:blank?)
      .to_sentence
  end

  def add_change_path(row)
    row[:change_path] = Rails.application.routes.url_helpers.candidate_interface_personal_details_edit_path
    row
  end

  def boolean_to_word(boolean)
    return '' if boolean.nil?

    boolean ? 'yes' : 'no'
  end
end
