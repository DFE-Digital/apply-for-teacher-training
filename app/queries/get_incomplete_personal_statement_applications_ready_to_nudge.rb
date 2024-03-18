class GetIncompletePersonalStatementApplicationsReadyToNudge
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
      .unsubmitted
      .inactive_since(7.days.ago)
      .with_completion(COMPLETION_ATTRS)
      .current_cycle
      .where(INCOMPLETION_ATTRS.map { |attr| "#{attr} = false" }.join(' AND '))
      .has_not_received_email(MAILER, MAIL_TEMPLATE)
      .includes(:application_choices).where('application_choices.status': 'unsubmitted')
  end
end
