class StartOfCycleNotificationWorker
  include Sidekiq::Worker

  def perform(service, hours_remaining = 1)
    @service = service
    @hours_remaining = hours_remaining

    providers_scope.limit(fetch_limit).each do |provider|
      provider.provider_users.each do |provider_user|
        unless ChaserSent.exists?(chased: provider_user, chaser_type: mailer_method)
          ProviderMailer.send(mailer_method, provider_user).deliver_later
          ChaserSent.create!(chased: provider_user, chaser_type: mailer_method)
        end

        next if service == :apply

        relationships_pending = relationships_user_can_setup(provider_user, provider)

        next if relationships_pending.blank?
        next if ChaserSent.exists?(chased: provider_user, chaser_type: setup_mailer_method)

        partner_organisations = relationships_pending.map { |relationship| relationship.partner_organisation(provider) }.compact

        if partner_organisations.any?
          ProviderMailer.send(setup_mailer_method, provider_user, partner_organisations).deliver_later
          ChaserSent.create!(chased: provider_user, chaser_type: setup_mailer_method)
        end
      end

      ChaserSent.create!(chased: provider, chaser_type: provider_chaser_type)
    end
  end

private

  attr_reader :service, :hours_remaining

  def fetch_limit
    (provider_count / hours_remaining).ceil
  end

  def provider_count
    providers_scope.count
  end

  def relationships_user_can_setup(provider_user, provider)
    return [] unless provider_user.provider_permissions.find_by(provider: provider).manage_organisations

    ProviderSetup.new(provider_user: provider_user).relationships_pending
  end

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
