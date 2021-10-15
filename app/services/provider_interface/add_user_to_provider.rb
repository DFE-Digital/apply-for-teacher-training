module ProviderInterface
  class AddUserToProvider
    include ImpersonationAuditHelper

    attr_accessor :actor, :provider, :email_address, :first_name, :last_name, :permissions

    def initialize(actor:, provider:, email_address:, first_name:, last_name:, permissions:)
      @actor = actor
      @provider = provider
      @email_address = email_address.downcase
      @first_name = first_name
      @last_name = last_name
      @permissions = permissions
    end

    def call!
      audit(actor) do
        ActiveRecord::Base.transaction do
          assert_actor_can_manage_users_for_provider!

          provider_user = find_or_create_provider_user!
          create_provider_permissions!(provider_user)
          send_permissions_granted_email(provider_user)
        end
      end
    end

  private

    def assert_actor_can_manage_users_for_provider!
      return if actor.authorisation.can_manage_users_for?(provider: provider)

      raise ProviderAuthorisation::NotAuthorisedError, 'You are not allowed to add users to this provider'
    end

    def find_or_create_provider_user!
      provider_user = ProviderUser.find_or_initialize_by(email_address: email_address)
      provider_user.first_name = first_name
      provider_user.last_name = last_name

      new_user = provider_user.new_record?
      provider_user.save!

      if new_user
        create_notification_preferences!(provider_user)
      end

      provider_user
    end

    def create_notification_preferences!(provider_user)
      ProviderUserNotificationPreferences.create!(provider_user: provider_user)
    end

    def create_provider_permissions!(provider_user)
      ProviderPermissions.create!(provider: provider, provider_user: provider_user) do |provider_permissions|
        ProviderPermissions::VALID_PERMISSIONS.each do |permission|
          provider_permissions.send("#{permission}=", permissions.include?(permission.to_s))
        end
      end
    end

    def send_permissions_granted_email(provider_user)
      ProviderMailer.permissions_granted(provider_user, provider, permissions, actor)
    end
  end
end
