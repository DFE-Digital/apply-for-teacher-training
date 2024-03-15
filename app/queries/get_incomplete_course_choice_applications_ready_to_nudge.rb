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
      .where.missing(:application_choices)
  end
end
