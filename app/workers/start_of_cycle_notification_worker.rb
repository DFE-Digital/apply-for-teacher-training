class StartOfCycleNotificationWorker
  include Sidekiq::Worker

  def perform(service, batch_size = 100)
    @service = service

    providers_scope.find_each(batch_size: batch_size) do |provider|
      provider.provider_users.where.not(Arel.sql(chaser_sent_sql)).each do |provider_user|
        ProviderMailer.send(mailer_method, provider_user)
        ChaserSent.create!(chased: provider_user, chaser_type: mailer_method)

        next if service == :apply
        next unless provider_user.provider_permissions.find_by(provider: provider).manage_organisations
        next if ProviderSetup.new(provider_user: provider_user).relationships_pending.blank?
        next if ChaserSent.exists?(chased: provider_user, chaser_type: setup_mailer_method)

        ProviderMailer.send(setup_mailer_method, provider_user)
        ChaserSent.create!(chased: provider_user, chaser_type: setup_mailer_method)
      end

      ChaserSent.create!(chased: provider, chaser_type: provider_chaser_type)
    end
  end

private

  attr_reader :service

  def providers_scope
    Provider
      .joins('INNER JOIN provider_users_providers ON providers.id = provider_users_providers.provider_id')
      .joins('INNER JOIN provider_users ON provider_users.id = provider_users_providers.provider_user_id')
      .where.not(Arel.sql(provider_chaser_sent_sql))
      .order('providers.name')
      .distinct
  end

  def provider_chaser_sent_sql
    <<-SQL.squish
      EXISTS(
        SELECT 1
        FROM chasers_sent
        WHERE chased_type = 'Provider'
        AND chased_id = providers.id
        AND chaser_type = '#{provider_chaser_type}'
      )
    SQL
  end

  def chaser_sent_sql
    <<-SQL
      EXISTS(
        SELECT 1
        FROM chasers_sent
        WHERE chased_id = provider_users.id
        AND chased_type = 'ProviderUser'
        AND chaser_type = '#{mailer_method}'
      )
    SQL
  end

  def mailer_method
    "#{service}_service_is_now_open"
  end

  def setup_mailer_method
    'set_up_organisation_permissions'
  end

  def provider_chaser_type
    "#{service}_service_open_organisation_notification"
  end
end
