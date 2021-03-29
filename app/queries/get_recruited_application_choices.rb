class GetRecruitedApplicationChoices
  INCLUDES = [
    application_form: %i[candidate english_proficiency application_qualifications],
    offered_course_option: [{ course: %i[provider] }, :site],
  ].freeze

  def self.call(recruitment_cycle_year:)
    ApplicationChoice.includes(INCLUDES)
      .where(application_forms: { recruitment_cycle_year: recruitment_cycle_year })
      .where.not(recruited_at: nil)
  end
end
