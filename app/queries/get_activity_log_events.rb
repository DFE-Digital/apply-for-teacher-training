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

  def self.old_call(application_choices:, since: nil)
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
      .where(auditable_id: application_choices.select(:application_form_id).distinct, auditable_type: 'ApplicationForm', action: :update)
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

  def self.new_call(application_choices:, since: nil)
    #provider_ids = application_choices.pluck(:provider_ids).flatten.uniq.join(',')

    sql = <<~SQL
      WITH application_choices_cte AS (
          SELECT id, application_form_id
          FROM application_choices
          WHERE
          (provider_ids @> '{16}'::bigint[]
           OR provider_ids @> '{4}'::bigint[]
           OR provider_ids @> '{3}'::bigint[]
           OR provider_ids @> '{1}'::bigint[]
           OR provider_ids @> '{2}'::bigint[]
          )
            AND current_recruitment_cycle_year IN (2024, 2023)
            AND status IN ('awaiting_provider_decision', 'interviewing', 'offer', 'pending_conditions',
                           'recruited', 'rejected', 'declined', 'withdrawn', 'conditions_not_met',
                           'offer_withdrawn', 'offer_deferred', 'inactive')
      ),
      filtered_audits AS (
          SELECT a.*
          FROM audits a
          JOIN application_choices_cte ac ON
              (a.auditable_id = ac.id AND a.auditable_type = 'ApplicationChoice')
              OR (a.associated_id = ac.id AND a.associated_type = 'ApplicationChoice')
              OR (a.auditable_id = ac.application_form_id AND a.auditable_type = 'ApplicationForm')
          WHERE a.created_at >= '2022-09-06 17:01:23.167795'
            AND (
              (a.auditable_type = 'ApplicationChoice' AND a.action = 'update'
                AND (
                    jsonb_exists(a.audited_changes, 'reject_by_default_feedback_sent_at')
                    OR jsonb_exists(a.audited_changes, 'course_changed_at')
                    OR jsonb_exists(a.audited_changes, 'offer_changed_at')
                    OR a.audited_changes::jsonb #>> '{status,1}' IN (
                        'awaiting_provider_decision', 'offer', 'pending_conditions', 'recruited',
                        'rejected', 'declined', 'withdrawn', 'conditions_not_met', 'offer_withdrawn',
                        'offer_deferred', 'inactive'
                      )
                    AND NOT a.audited_changes @> '{"status": ["interviewing", "awaiting_provider_decision"]}'::jsonb
                )
              )
              OR (a.auditable_type = 'ApplicationForm' AND a.action = 'update'
                AND (
                    jsonb_exists(a.audited_changes, 'date_of_birth')
                    OR jsonb_exists(a.audited_changes, 'first_name')
                    OR jsonb_exists(a.audited_changes, 'last_name')
                    OR jsonb_exists(a.audited_changes, 'phone_number')
                    OR jsonb_exists(a.audited_changes, 'address_line1')
                    OR jsonb_exists(a.audited_changes, 'address_line2')
                    OR jsonb_exists(a.audited_changes, 'address_line3')
                    OR jsonb_exists(a.audited_changes, 'address_line4')
                    OR jsonb_exists(a.audited_changes, 'country')
                    OR jsonb_exists(a.audited_changes, 'postcode')
                    OR jsonb_exists(a.audited_changes, 'region_code')
                    OR jsonb_exists(a.audited_changes, 'interview_preferences')
                    OR jsonb_exists(a.audited_changes, 'disability_disclosure')
                ) AND EXISTS (
                  SELECT 1
                  WHERE ARRAY['date_of_birth', 'first_name', 'last_name', 'phone_number', 'address_line1',
                              'address_line2', 'address_line3', 'address_line4', 'country', 'postcode',
                              'region_code', 'interview_preferences', 'disability_disclosure']
                  @> (
                    SELECT ARRAY(
                      SELECT jsonb_object_keys(a.audited_changes)
                    )
                  )
                )
              )
            )
      )
      SELECT filtered_audits.*, ac.id AS application_choice_id
      FROM filtered_audits
      JOIN application_choices_cte ac ON
          (filtered_audits.auditable_id = ac.id AND filtered_audits.auditable_type = 'ApplicationChoice')
          OR (filtered_audits.associated_id = ac.id AND filtered_audits.associated_type = 'ApplicationChoice')
          OR (filtered_audits.auditable_id = ac.application_form_id AND filtered_audits.auditable_type = 'ApplicationForm')
      ORDER BY filtered_audits.created_at DESC
    SQL

    results = ActiveRecord::Base.connection.exec_query(sql)

    results.map do |row|
      audit = Audited::Audit.new(row.except('application_choice_id'))
      audit.audited_changes = JSON.parse(audit.audited_changes)
      audit.define_singleton_method(:application_choice_id) { row['application_choice_id'] }
      audit
    end
  end

  def self.call(application_choices:, since: nil)
    since ||= application_choices.includes(:application_form).minimum('application_forms.created_at')

    changes_exist = <<~SQL
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

    results = Audited::Audit.with(
      application_choices_cte: application_choices.to_sql,
    ).where('audits.created_at >= ?', since)
    .where(auditable_type:'ApplicationChoice',
      action: 'update',
    ).where(
      "#{application_choice_audits_filter_sql}
      OR audits.auditable_type = 'ApplicationForm' AND audits.action = 'update'
      AND (#{application_form_audits_filter_sql})
      AND (#{changes_exist})",
    ).select('audits.*, ac.id as application_choice_id').joins(
      "join application_choices_cte ac on(
        audits.auditable_id = ac.id AND audits.auditable_type = 'ApplicationChoice'
        OR (audits.associated_id = ac.id AND audits.associated_type = 'ApplicationChoice')
        OR (audits.auditable_id = ac.application_form_id AND audits.auditable_type = 'ApplicationForm')
      )"
    ).order('audits.created_at DESC')

    old = self.old_call(application_choices:, since:)
    new_query = self.new_call(application_choices:, since:)
#    byebug
    results
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
