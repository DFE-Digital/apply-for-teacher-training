module SupportInterface
  class StartOfCycleNotifier
    attr_reader :service, :batch_size, :year

    def initialize(service:, batch_size: 500, year: 2022)
      @service = service
      @batch_size = batch_size
      @year = year

      raise_unless_service_opens_today!
    end

    def call
      provider_users_scope.find_each(batch_size: batch_size) do |user|
        # TODO: We may need to pass a provider + permissions here
        # to avoid the mailer doing additional db work.
        ProviderMailer.send(mailer_method, user)
      end
    end

  private

    def provider_users_scope
      scope = service == :find ? all_provider_users : provider_users_who_need_to_set_up_org_permissions
      scope = scope.includes(:providers).order('providers.name', 'provider_users.email_address')
      scope.where.not(Arel.sql(email_exists_sql)).distinct
    end

    def email_exists_sql
      <<-SQL.squish
        EXISTS(
          SELECT 1
          FROM emails
          WHERE emails.to = provider_users.email_address
          AND emails.delivery_status IN ('delivered', 'pending')
          AND emails.mailer = 'provider_mailer'
          AND emails.mail_template = '#{mail_template}'
        )
      SQL
    end

    def all_provider_users
      ProviderUser.all
    end

    def provider_users_who_need_to_set_up_org_permissions
      ProviderUser
        .joins(provider_permissions: :provider)
        .joins('LEFT JOIN provider_relationship_permissions tprp ON providers.id = tprp.training_provider_id AND tprp.setup_at IS NULL')
        .joins('LEFT JOIN provider_relationship_permissions rprp ON providers.id = rprp.ratifying_provider_id AND rprp.setup_at IS NULL')
        .where(provider_permissions: { manage_organisations: true })
    end

    def mail_template
      "#{service}_service_is_now_open"
    end
    alias mailer_method mail_template

    def raise_unless_service_opens_today!
      current_cycles = CycleTimetable::CYCLE_DATES[year]
      service_opening_date = current_cycles[:"#{service}_opens"]

      unless Time.zone.now.between?(service_opening_date.beginning_of_day, service_opening_date.end_of_day)
        raise "Error: #{service} opens on #{service_opening_date.to_s(:govuk_date_and_time)}"
      end
    end
  end
end
