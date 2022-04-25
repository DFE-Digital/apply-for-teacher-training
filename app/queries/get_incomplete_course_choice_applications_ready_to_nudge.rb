class GetIncompleteCourseChoiceApplicationsReadyToNudge
  MAILER = 'candidate_mailer'.freeze
  MAIL_TEMPLATE = 'nudge_unsubmitted_with_incomplete_courses'.freeze
  COMPLETION_ATTRS = %w[
    becoming_a_teacher_completed
    subject_knowledge_completed
    references_completed
  ].freeze

  def call
    ApplicationForm
      .where(submitted_at: nil)
      .where('application_forms.updated_at < ?', 7.days.ago)
      .where(recruitment_cycle_year: RecruitmentCycle.current_year)
      .where(COMPLETION_ATTRS.map { |attr| "#{attr} = true" }.join(' AND '))
      .where(
        'NOT EXISTS (:application_choices)',
        application_choices: ApplicationChoice
          .select(1)
          .where('application_choices.application_form_id = application_forms.id')
      )
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
