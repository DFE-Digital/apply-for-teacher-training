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

  def self.call(application_choices:, since: nil)
    since ||= Time.zone.local(2018, 1, 1) # before the pilot began, i.e. all records

    ActivityLogEvent.includes(INCLUDES).from <<~COMBINE_AUDITS_WITH_APPLICATION_CHOICES_SCOPE.squish
      (
        SELECT a.*
          FROM audits a
          INNER JOIN application_choices ac
            ON auditable_id = ac.id
              AND auditable_type = 'ApplicationChoice'
              AND action = 'update'
              AND (
                jsonb_exists(audited_changes, 'status')
                OR jsonb_exists(audited_changes, 'reject_by_default_feedback_sent_at')
              )
          INNER JOIN (#{application_choices.to_sql}) visible
            ON ac.id = visible.id
          WHERE a.created_at >= '#{since.iso8601}'::TIMESTAMPTZ
          ORDER BY a.created_at DESC
      ) AS audits
    COMBINE_AUDITS_WITH_APPLICATION_CHOICES_SCOPE
  end
end
