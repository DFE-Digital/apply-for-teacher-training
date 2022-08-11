class GetIncompleteReferenceApplicationsReadyToNudge
  MAILER = 'candidate_mailer'.freeze
  MAIL_TEMPLATE = 'nudge_unsubmitted_with_incomplete_references'.freeze
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
  ].freeze
  SCIENCE_GCSE_COMPLETION_ATTR = 'science_gcse_completed'.freeze
  EFL_COMPLETION_ATTR = 'efl_completed'.freeze

  def call
    uk_and_irish_names = NATIONALITIES.select do |code, _name|
      code.in?(ApplicationForm::BRITISH_OR_IRISH_NATIONALITIES)
    end.map(&:second)
    uk_and_irish = uk_and_irish_names.map { |name| ActiveRecord::Base.connection.quote(name) }.join(',')

    scope = if FeatureFlag.active?(:new_references_flow)
              ApplicationForm.where(recruitment_cycle_year: ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR)
            else
              ApplicationForm.current_cycle
            end

    scope
      .unsubmitted
      .inactive_since(7.days.ago)
      .with_completion(COMMON_COMPLETION_ATTRS)
      .has_not_received_email(MAILER, MAIL_TEMPLATE)
      .and(ApplicationForm
      .where(science_gcse_completed: true)
      .or(
        ApplicationForm.where(
          'NOT EXISTS (:primary)',
          primary: ApplicationChoice
            .select(1)
            .joins(:course)
            .where('application_choices.application_form_id = application_forms.id')
            .where('courses.level': 'primary'),
        ),
      ))
    .and(ApplicationForm
      .where(efl_completed: true)
      .or(
        ApplicationForm.where(
          "first_nationality IN (#{uk_and_irish})",
        ),
      ))
    .joins(
      "LEFT OUTER JOIN \"references\" ON \"references\".application_form_id = application_forms.id AND \"references\".feedback_status IN ('feedback_requested', 'feedback_provided')",
    )
    .group('application_forms.id')
    .having('count("references".id) < 2')
  end
end
