class GetUnsubmittedApplicationsReadyToNudge
  COMMON_COMPLETION_ATTRS = %w[
    course_choices_completed
    degrees_completed
    other_qualifications_completed
    volunteering_completed
    work_history_completed
    personal_details_completed
    contact_details_completed
    english_gcse_completed
    maths_gcse_completed
    training_with_a_disability_completed
    safeguarding_issues_completed
    becoming_a_teacher_completed
    subject_knowledge_completed
    interview_preferences_completed
    references_completed
  ].freeze
  SCIENCE_GCSE_COMPLETION_ATTR = 'science_gcse_completed'
  EFL_COMPLETION_ATTR = 'efl_completed'

  def call
    ApplicationForm
      .left_joins(application_choices: :course)
      .where(submitted_at: nil)
      .where('application_forms.updated_at < ?', 7.days.ago)
      .where(recruitment_cycle_year: RecruitmentCycle.current_year)
      .where(COMMON_COMPLETION_ATTRS.map { |attr| "#{attr} = true" }.join(' AND '))
  end
end
