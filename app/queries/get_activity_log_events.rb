class GetActivityLogEvents
  attr_reader :application_choices

  def initialize(application_choices:)
    @application_choices = application_choices
  end

  def call(since: nil)
    since ||= Time.zone.local(2018, 1, 1)

    Audited::Audit.from <<~COMBINE_AUDITS_WITH_APPLICATION_CHOICES_SCOPE.squish
      (
        SELECT a.*
          FROM audits a
          INNER JOIN application_choices ac
            ON auditable_id = ac.id
              AND auditable_type = 'ApplicationChoice'
              AND action = 'update'
          INNER JOIN (#{application_choices.to_sql}) visible
            ON ac.id = visible.id
          WHERE a.created_at >= '#{since.iso8601}'::TIMESTAMPTZ
          ORDER BY a.created_at DESC
      ) AS audits
    COMBINE_AUDITS_WITH_APPLICATION_CHOICES_SCOPE
  end
end
