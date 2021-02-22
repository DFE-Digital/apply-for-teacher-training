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
      offered_course_option
    ],
  }.freeze

  INCLUDE_APPLICATION_CHOICE_CHANGES_TO = %w[
    reject_by_default_feedback_sent_at
    offer_changed_at
  ].freeze

  IGNORE_STATUS = %i[interviewing].freeze

  def self.call(application_choices:, since: nil)
    since ||= Time.zone.local(2018, 1, 1) # before the pilot began, i.e. all records

    application_choices_join_sql = <<~COMBINE_AUDITS_WITH_APPLICATION_CHOICES_SCOPE_AND_FILTER.squish
      INNER JOIN (#{application_choices.to_sql}) ac
        ON (
          auditable_type = 'ApplicationChoice'
          AND auditable_id = ac.id
          AND action = 'update'
          AND ( #{application_choice_audits_filter_sql} )
        ) OR (
          associated_type = 'ApplicationChoice'
          AND associated_id = ac.id
        )
    COMBINE_AUDITS_WITH_APPLICATION_CHOICES_SCOPE_AND_FILTER

    Audited::Audit.includes(INCLUDES)
                  .joins(application_choices_join_sql)
                  .where('audits.created_at >= ?', since)
                  .order('audits.created_at DESC')
  end

  def self.application_choice_audits_filter_sql
    application_choice_audits_filter = INCLUDE_APPLICATION_CHOICE_CHANGES_TO.map { |f|
      "jsonb_exists(audited_changes, '#{f}')"
    }.join(' OR ')

    filtered_statuses = ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER - IGNORE_STATUS
    status_transitions_to_include = filtered_statuses.map { |status| "'#{status}'" }.join(', ')

    application_choice_audits_filter += " OR audited_changes::json#>>'{status, 1}' IN (#{status_transitions_to_include})"
    application_choice_audits_filter + ignore_interview_cancelled_application_choice_status_change_sql
  end

  def self.ignore_interview_cancelled_application_choice_status_change_sql
    %( AND NOT audited_changes @> '{"status" : ["interviewing", "awaiting_provider_decision"]}')
  end
end
