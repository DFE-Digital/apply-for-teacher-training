class GetRecruitedApplicationChoices
  INCLUDES = [
    application_form: %i[candidate english_proficiency application_qualifications],
    current_course_option: [{ course: %i[provider] }, :site],
  ].freeze

  def self.call(recruitment_cycle_year:, changed_since: nil)
    application_choices = ApplicationChoice
    application_choices = application_choices.where('application_choices.updated_at > ?', changed_since) if changed_since.present?

    application_choices
      .includes(INCLUDES)
      .joins(:current_course)
      .merge(Course.in_cycle(recruitment_cycle_year))
      .where.not(recruited_at: nil)
  end
end
