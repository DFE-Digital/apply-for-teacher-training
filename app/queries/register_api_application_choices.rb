class RegisterAPIApplicationChoices
  INCLUDES = [
    application_form: %i[candidate english_proficiency application_qualifications],
    current_course_option: [{ course: %i[provider accredited_provider] }, :site],
  ].freeze

  def self.call(recruitment_cycle_year:, changed_since: nil)
    application_choices = ApplicationChoice
    application_choices = application_choices.where('application_choices.updated_at > ?', changed_since) if changed_since.present?

    application_choices_in_year = application_choices
      .includes(INCLUDES)
      .joins(:current_course)
      .merge(Course.in_cycle(recruitment_cycle_year))

    recruited_application_choices = application_choices_in_year.where.not(recruited_at: nil)
    pending_conditions_application_choices = application_choices_in_year.where(status: :pending_conditions)

    recruited_application_choices
      .or(pending_conditions_application_choices)
      .distinct
      .order(:updated_at, :id)
  end
end
