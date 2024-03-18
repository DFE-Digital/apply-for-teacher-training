class GetUnsubmittedApplicationsReadyToNudge
  MAILER = 'candidate_mailer'.freeze
  MAIL_TEMPLATE = 'nudge_unsubmitted'.freeze
  COMMON_COMPLETION_ATTRS = (ApplicationForm::SECTION_COMPLETED_FIELDS - %w[science_gcse efl course_choices])
    .map { |field| "#{field}_completed" }.freeze

  def call
    uk_and_irish_names = NATIONALITIES.select do |code, _name|
      code.in?(ApplicationForm::BRITISH_OR_IRISH_NATIONALITIES)
    end.map(&:second)
    uk_and_irish = uk_and_irish_names.map { |name| ActiveRecord::Base.connection.quote(name) }.join(',')

    ApplicationForm
      .unsubmitted
      .inactive_since(7.days.ago)
      .with_completion(COMMON_COMPLETION_ATTRS)
      .current_cycle
      .has_not_received_email(MAILER, MAIL_TEMPLATE)
      .includes(:application_choices).where('application_choices.status': 'unsubmitted')
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
  end
end
