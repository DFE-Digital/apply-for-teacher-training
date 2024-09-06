class GetActivityLogEvents
  INCLUDES = {
    user: %i[
      provider_user
      support_user
    ],
    auditable: %i[
      application_form
      course_option
      course
      site
      provider
      accredited_provider
      current_course_option
    ],
  }.freeze

  INCLUDE_APPLICATION_FORM_CHANGES_TO = ApplicationForm::ColumnSectionMapping.by_section(
    'personal_information',
    'contact_information',
    'interview_preferences',
    'disability_disclosure',
  )

  DATABASE_CHANGE_KEYS = INCLUDE_APPLICATION_FORM_CHANGES_TO.map { |e| "'#{e}'" }.join(',')

  INCLUDE_APPLICATION_CHOICE_CHANGES_TO = %w[
    reject_by_default_feedback_sent_at
    course_changed_at
    offer_changed_at
  ].freeze

  IGNORE_STATUS = %i[interviewing].freeze

  def self.call(application_choices:, since: nil)
    since ||= application_choices.includes(:application_form).minimum('application_forms.created_at')

    sql_string = <<~SQL
      EXISTS (
              SELECT 1
              WHERE ARRAY[#{DATABASE_CHANGE_KEYS}] @> (
                SELECT ARRAY(SELECT jsonb_object_keys(a.audited_changes)
                FROM audits a
                WHERE a.id = audits.id
                )
              )
            )
    SQL

    where_auditable_is_application_form = Audited::Audit
                                            .where(auditable_id: application_choices.pluck(:application_form_id), auditable_type: 'ApplicationForm', action: :update)
                                            .where(application_form_audits_filter_sql)
                                            .where(sql_string)

    where_associated_is_application_choice = Audited::Audit
                                               .where(associated: application_choices)
                                               .where.not(auditable_type: %w[OfferCondition ApplicationExperience ApplicationWorkHistoryBreak])

    application_choices_query = Audited::Audit.where(auditable: application_choices, action: :update)
                                        .where(application_choice_audits_filter_sql)

    sub_query = application_choices_query
                  .or(where_auditable_is_application_form)
                  .or(where_associated_is_application_choice)

    sub_query.includes(INCLUDES)
                  .where('audits.created_at >= ?', since)
                  .order('audits.created_at DESC')
  end

  def self.application_form_audits_filter_sql
    INCLUDE_APPLICATION_FORM_CHANGES_TO.map do |change|
      "(audited_changes::jsonb ? '#{change}')"
    end.join(' OR ')
  end

  def self.application_choice_audits_filter_sql
    application_choice_audits_filter = INCLUDE_APPLICATION_CHOICE_CHANGES_TO.map do |change|
      "(audited_changes::jsonb ? '#{change}')"
    end.join(' OR ')

    filtered_statuses = ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER - IGNORE_STATUS
    status_transitions_to_include = filtered_statuses.map { |status| "'#{status}'" }.join(', ')

    application_choice_audits_filter += " OR audited_changes::json#>>'{status, 1}' IN (#{status_transitions_to_include})"
    application_choice_audits_filter + ignore_interview_cancelled_application_choice_status_change_sql
  end

  def self.ignore_interview_cancelled_application_choice_status_change_sql
    %( AND NOT audited_changes @> '{"status" : ["interviewing", "awaiting_provider_decision"]}')
  end
end
