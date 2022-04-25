class GetIncompletePersonalStatementApplicationsReadyToNudge
  MAILER = 'candidate_mailer'.freeze
  MAIL_TEMPLATE = 'nudge_unsubmitted_with_incomplete_personal_statement'.freeze
  COMPLETION_ATTRS = %w[
    references_completed
    course_choices_completed
  ].freeze
  INCOMPLETION_ATTRS = %w[
    personal_details_completed
  ].freeze

  def call
    ApplicationForm
      .where(submitted_at: nil)
      .where('application_forms.updated_at < ?', 7.days.ago)
      .where(recruitment_cycle_year: RecruitmentCycle.current_year)
      .where(COMPLETION_ATTRS.map { |attr| "#{attr} = true" }.join(' AND '))
      .where(INCOMPLETION_ATTRS.map { |attr| "#{attr} = false" }.join(' AND '))
      .where(
        'NOT EXISTS (:existing_email)',
        existing_email: Email
          .select(1)
          .where('emails.application_form_id = application_forms.id')
          .where(mailer: MAILER)
          .where(mail_template: MAIL_TEMPLATE),
      )
  end
end
