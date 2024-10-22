class GetIncompletePersonalStatementApplicationsReadyToNudge
  # The purpose of this nudge is to contact candidates who have
  # - completed the references section of the application form
  # - has made application choices
  # - but have NOT completed the personal statement
  MAILER = 'candidate_mailer'.freeze
  MAIL_TEMPLATE = 'nudge_unsubmitted_with_incomplete_personal_statement'.freeze
  COMPLETION_ATTRS = %w[
    references_completed
  ].freeze
  INCOMPLETION_ATTRS = %w[
    becoming_a_teacher_completed
  ].freeze

  def call
    ApplicationForm
      # Only candidates with unsubmitted application_choices
      .joins(:application_choices).where('application_choices.status': 'unsubmitted')
      # Filter out candidates who should not receive emails about their accounts
      .joins(:candidate).merge(Candidate.for_marketing_or_nudge_emails)
      # Only include candidates who have not submitted ANY applications. unsubmitted == NEVER submitted.
      # Candidates can't submit an application choice without a personal statement, so this is just here to be explicit, it won't practically change anything.
      .unsubmitted
      .inactive_since(7.days.ago)
      .current_cycle
      # They have completed their references
      .with_completion(COMPLETION_ATTRS)
      # But have not completed their personal statements
      .where(INCOMPLETION_ATTRS.map { |attr| "#{attr} = false" }.join(' AND '))
      .has_not_received_email(MAILER, MAIL_TEMPLATE)
  end
end
