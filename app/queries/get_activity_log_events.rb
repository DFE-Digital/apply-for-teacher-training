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

    application_form_changes_exist = <<~SQL
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
      .where(auditable_id: application_choices.pluck(:application_form_id).uniq, auditable_type: 'ApplicationForm', action: :update)
      .where(application_form_audits_filter_sql)
      .where(application_form_changes_exist)

    where_associated_is_application_choice = Audited::Audit
      .where(associated: application_choices)
      .where(auditable_type: %w[Interview])

    application_choices_query = Audited::Audit.where(auditable: application_choices, action: :update)
      .where(application_choice_audits_filter_sql)

    sub_query = application_choices_query
      .or(where_associated_is_application_choice)
      .or(where_auditable_is_application_form)

    # Join with application_choices, we need an application_choice_id on every audit
    sub_query.includes(INCLUDES)
      .where('audits.created_at >= ?', since)
      .select('audits.*, ac.id AS application_choice_id').joins(
        "INNER JOIN (#{application_choices.to_sql}) ac on (
          audits.auditable_id = ac.id AND audits.auditable_type = 'ApplicationChoice'
        ) OR (
          audits.associated_id = ac.id and audits.associated_type = 'ApplicationChoice'
        ) OR (
          audits.auditable_id = ac.application_form_id AND audits.auditable_type = 'ApplicationForm'
        )",
      ).order('audits.created_at DESC')
  end

  def self.application_form_audits_filter_sql
    INCLUDE_APPLICATION_FORM_CHANGES_TO.map do |change|
      "jsonb_exists(audited_changes, '#{change}')"
    end.join(' OR ')
  end

  def self.application_choice_audits_filter_sql
    application_choice_audits_filter = INCLUDE_APPLICATION_CHOICE_CHANGES_TO.map do |change|
      "jsonb_exists(audited_changes, '#{change}')"
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
