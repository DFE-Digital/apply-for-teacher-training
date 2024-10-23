class GetIncompleteCourseChoiceApplicationsReadyToNudge
  # The purpose of this nudge is to contact condidates who have
  # - Completed some of the most important bits of the application (references and personal statement)
  # - but have not made ANY application choices
  MAILER = 'candidate_mailer'.freeze
  MAIL_TEMPLATE = 'nudge_unsubmitted_with_incomplete_courses'.freeze
  COMPLETION_ATTRS = %w[
    becoming_a_teacher_completed
    references_completed
  ].freeze

  def call
    ApplicationForm
      # Filter out candidates who should not receive emails about their accounts
      .joins(:candidate).merge(Candidate.for_marketing_or_nudge_emails)
      .current_cycle
      .inactive_since(7.days.ago)
      # They have completed their references and the personal statement
      .with_completion(COMPLETION_ATTRS)
      .has_not_received_email(MAILER, MAIL_TEMPLATE)
      # They have not made any application choices
      .where.missing(:application_choices)
  end
end
