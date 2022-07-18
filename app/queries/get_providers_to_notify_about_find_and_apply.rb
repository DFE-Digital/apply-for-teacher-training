class GetProvidersToNotifyAboutFindAndApply
  def self.call
    Provider
      .joins('INNER JOIN provider_users_providers ON providers.id = provider_users_providers.provider_id')
      .joins('INNER JOIN provider_users ON provider_users.id = provider_users_providers.provider_user_id')
      .where.not(Arel.sql(providers_whose_users_have_been_chased))
      .order('providers.name')
      .distinct
  end

  def self.providers_whose_users_have_been_chased
    <<-SQL.squish
      EXISTS(
        SELECT 1
        FROM chasers_sent
        WHERE chased_type = 'Provider'
        AND chased_id = providers.id
        AND chaser_type = 'find_service_open_organisation_notification'
      )
    SQL
  end
end
