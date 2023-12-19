class GetIncompleteCourseChoiceApplicationsReadyToNudge
  MAILER = 'candidate_mailer'.freeze
  MAIL_TEMPLATE = 'nudge_unsubmitted_with_incomplete_courses'.freeze
  COMPLETION_ATTRS = %w[
    becoming_a_teacher_completed
    references_completed
  ].freeze

  def call
    ApplicationForm
      .unsubmitted
      .inactive_since(7.days.ago)
      .with_completion(COMPLETION_ATTRS)
      .current_cycle
      .has_not_received_email(MAILER, MAIL_TEMPLATE)
      .where(
        'NOT EXISTS (:application_choices)',
        application_choices: ApplicationChoice
          .select(1)
          .where('application_choices.application_form_id = application_forms.id'),
      )
  end
end
