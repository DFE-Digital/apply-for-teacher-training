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

  ONLY_CHANGES_TO = %w[
    status
    reject_by_default_feedback_sent_at
    offer_changed_at
  ].freeze

  def self.call(application_choices:, since: nil)
    since ||= Time.zone.local(2018, 1, 1) # before the pilot began, i.e. all records

    filter = ONLY_CHANGES_TO.map { |f| "jsonb_exists(audited_changes, '#{f}')" }
                            .join(' OR ')

    Audited::Audit.includes(INCLUDES)
                  .where(auditable: application_choices)
                  .where(action: :update)
                  .where(filter)
                  .where('created_at > ?', since)
                  .order(created_at: :desc)
  end
end
