class GetUnsubmittedApplicationsReadyToNudge
  # The purpose of this nudge is to contact candidates who have
  # - completed their application forms,
  # - made an application choice
  # - but NOT submitted anything.
  MAILER = 'candidate_mailer'.freeze
  MAIL_TEMPLATE = 'nudge_unsubmitted'.freeze
  COMMON_COMPLETION_ATTRS = (ApplicationForm::SECTION_COMPLETED_FIELDS - %w[science_gcse efl course_choices])
    .map { |field| "#{field}_completed" }.freeze

  def call
    uk_and_irish_names = NATIONALITIES.slice(*ApplicationForm::BRITISH_OR_IRISH_NATIONALITIES).map(&:second)

    ApplicationForm
      # Only candidates with unsubmitted application_choices
      .joins(:application_choices).where('application_choices.status': 'unsubmitted')
      # Filter out candidates who should not receive emails about their accounts
      .joins(:candidate).merge(Candidate.for_marketing_or_nudge_emails)
      .joins('LEFT OUTER JOIN application_choices ac_primary ON ac_primary.application_form_id = application_forms.id')
      .joins('LEFT OUTER JOIN course_options ON course_options.id = ac_primary.course_option_id')
      .joins("LEFT OUTER JOIN courses courses_primary ON courses_primary.id = course_options.course_id AND LOWER(courses_primary.level) = 'primary'")
      # Filter out anyone who has already received this message
      .has_not_received_email(MAILER, MAIL_TEMPLATE)
      # Only include candidates who have not submitted ANY applications. unsubmitted == NEVER submitted.
      .unsubmitted
      .current_cycle
      .inactive_since(7.days.ago)
      # Filter out people who haven't completed the application form
      .with_completion(COMMON_COMPLETION_ATTRS)
      # If the candidate is applying for a primary course, they also need to have compelted the science gcse section
      .where('application_forms.science_gcse_completed = TRUE OR courses_primary.id IS NULL')
      # Only Candidates who are likely to have a high level of English
      .where('application_forms.efl_completed = TRUE OR application_forms.first_nationality IN (?)', uk_and_irish_names)
      .distinct
  end
end
