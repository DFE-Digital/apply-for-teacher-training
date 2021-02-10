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

    application_choice_audits_filter = INCLUDE_APPLICATION_CHOICE_CHANGES_TO.map { |f|
      "jsonb_exists(audited_changes, '#{f}')"
    }.join(' OR ')

    filtered_statuses = ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER - IGNORE_STATUS
    status_transitions_to_include = filtered_statuses.map { |status| "'#{status}'" }.join(', ')

    application_choice_audits_filter += " OR audited_changes::json#>>'{status, 1}' IN (#{status_transitions_to_include})"

    Audited::Audit.includes(INCLUDES).from <<~COMBINE_AUDITS_WITH_APPLICATION_CHOICES_SCOPE_AND_FILTER.squish
      (
        SELECT a.*
          FROM audits a

          INNER JOIN (#{application_choices.to_sql}) ac
            ON (
              auditable_type = 'ApplicationChoice'
              AND auditable_id = ac.id
              AND action = 'update'
              AND ( #{application_choice_audits_filter} )
            ) OR (
              associated_type = 'ApplicationChoice'
              AND associated_id = ac.id
            )

          WHERE a.created_at >= '#{since.iso8601}'::TIMESTAMPTZ
          ORDER BY a.created_at DESC
      ) AS audits
    COMBINE_AUDITS_WITH_APPLICATION_CHOICES_SCOPE_AND_FILTER
  end
end
