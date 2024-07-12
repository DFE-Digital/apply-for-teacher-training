class GetIncompleteReferenceApplicationsReadyToNudge
  COMMON_COMPLETION_ATTRS_WITHOUT_REFERENCES = GetUnsubmittedApplicationsReadyToNudge::COMMON_COMPLETION_ATTRS.filter do |attr|
    attr != 'references_completed'
  end

  def call
    uk_and_irish_names = NATIONALITIES.select do |code, _name|
      code.in?(ApplicationForm::BRITISH_OR_IRISH_NATIONALITIES)
    end.map(&:second)

    ApplicationForm
      # Only candidates with application_choices
      .joins(:application_choices)
      .joins(:candidate)
      .joins("LEFT OUTER JOIN emails ON emails.application_form_id = application_forms.id AND emails.mailer = 'candidate_mailer' AND emails.mail_template = 'nudge_unsubmitted_with_incomplete_references'")
      .joins('LEFT OUTER JOIN application_choices ac_primary ON ac_primary.application_form_id = application_forms.id')
      .joins('LEFT OUTER JOIN course_options ON course_options.id = ac_primary.course_option_id')
      .joins("LEFT OUTER JOIN courses courses_primary ON courses_primary.id = course_options.course_id AND LOWER(courses_primary.level) = 'primary'")
      .current_cycle
      # Only applications forms with at least one unsubmitted application choice (inflight)
      .where('application_choices.status': 'unsubmitted')
      # Filter out candidates who should not be receiving emails about their accounts
      .where(candidates: { submission_blocked: false, account_locked: false, unsubscribed_from_emails: false })
      # have not already seen this message
      .where(emails: { id: nil })
      .inactive_since(7.days.ago)
      # They've completed most section, but not references
      .with_completion(COMMON_COMPLETION_ATTRS_WITHOUT_REFERENCES)
      .where(references_completed: false)
      # If they are applying for primary courses, they will also need to have completed a science gcse
      .where('application_forms.science_gcse_completed = TRUE OR courses_primary.id IS NULL')
      # Only Candidates who are likely to have a high level of English
      .where('application_forms.efl_completed = TRUE OR application_forms.first_nationality IN (?)', uk_and_irish_names)
      .distinct
  end
end
