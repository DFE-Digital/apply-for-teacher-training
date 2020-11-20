class GetProviderActivityLogEvents
  attr_reader :provider_user

  def initialize(provider_user:)
    @provider_user = provider_user
  end

  def call
    scope = GetApplicationChoicesForProviders.call(providers: provider_user.providers)

    Audited::Audit.from <<~COMBINE_AUDITS_WITH_APPLICATION_CHOICES_SCOPE.squish
      (
        SELECT a.*, '' AS description
          FROM audits a
          INNER JOIN application_choices ac
            ON auditable_id = ac.id
              AND auditable_type = 'ApplicationChoice'
              AND action = 'update'
          INNER JOIN (#{scope.to_sql}) visible
            ON ac.id = visible.t0_r0
          ORDER BY a.created_at DESC
      ) AS audits
    COMBINE_AUDITS_WITH_APPLICATION_CHOICES_SCOPE
  end
end
