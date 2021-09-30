class StartOfCycleNotificationWorker
  include Sidekiq::Worker

  def perform(service)
    return unless CycleTimetable.service_opens_today?(service, year: RecruitmentCycle.current_year)

    @service = service

    providers_scope.limit(fetch_limit).each do |provider|
      provider.provider_users.each do |provider_user|
        unless ChaserSent.exists?(chased: provider_user, chaser_type: mailer_method)
          ProviderMailer.send(mailer_method, provider_user).deliver_later
          ChaserSent.create!(chased: provider_user, chaser_type: mailer_method)
        end

        next if service == 'apply'

        next unless provider_user.provider_permissions.find_by(provider: provider).manage_organisations
        next if ChaserSent.exists?(chased: provider_user, chaser_type: setup_mailer_method)

        ProviderMailer.send(setup_mailer_method, provider_user, relationships_to_set_up(provider_user)).deliver_later
        ChaserSent.create!(chased: provider_user, chaser_type: setup_mailer_method)
      end

      ChaserSent.create!(chased: provider, chaser_type: provider_chaser_type)
    end
  end

private

  attr_reader :service

  def fetch_limit
    (provider_count / hours_remaining).ceil
  end

  def provider_count
    providers_scope.count
  end

  def hours_remaining
    notify_until.hour - Time.zone.now.hour
  end

  def notify_until
    Time.zone.now.change(hour: 16)
  end

  def relationships_to_set_up(provider_user)
    relationships_pending = ProviderSetup.new(provider_user: provider_user).relationships_pending
    training_providers = relationships_pending.map(&:training_provider) & provider_user.providers

    relationships = relationships_pending.each_with_object({}) do |rel, hash|
      if training_providers.include?(rel.training_provider)
        hash[rel.training_provider.name] ||= []
        hash[rel.training_provider.name] << rel.ratifying_provider.name
      else
        hash[rel.ratifying_provider.name] ||= []
        hash[rel.ratifying_provider.name] << rel.training_provider.name
      end
    end
    relationships.sort_by { |k, v| [k, v.sort!] }.to_h
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
