module EndOfCycle
  class SendRejectByDefaultReminderToProvidersService
    def initialize(provider)
      @provider = provider
    end

    def call
      return if provider_users.blank?

      provider_users.find_each do |provider_user|
        next if already_chased?(provider_user)
        next unless prefers_emails?(provider_user)

        ProviderMailer.public_send(chaser_type, provider_user).deliver_later

        ChaserSent.create!(chased: provider_user, chaser_type:)
      end
    end

  private

    def provider_users
      @provider_users = @provider.provider_users
    end

    def chaser_type
      :respond_to_applications_before_reject_by_default_date
    end

    def already_chased?(provider_user)
      ChaserSent
        .since_application_deadline
        .find_by(chased: provider_user, chaser_type: chaser_type.to_s).present?
    end

    def prefers_emails?(provider_user)
      provider_user.notification_preferences.application_received == true
    end
  end
end
