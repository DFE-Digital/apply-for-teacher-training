module ProviderInterface
  class SaveProviderUserService
    include ImpersonationAuditHelper

    attr_accessor :wizard

    def initialize(actor:, wizard:)
      @actor = actor
      self.wizard = wizard
    end

    def call!
      audit(@actor) do
        assert_permissions_for_providers!
        if email_exists?
          update_user
        else
          create_user
        end
      end
    end

  private

    def assert_permissions_for_providers!
      authorisation = ProviderAuthorisation.new(actor: @actor)
      return if @wizard.provider_permissions.keys.all? { |provider_id| authorisation.can_manage_users_for?(provider: Provider.find(provider_id)) }

      raise ProviderAuthorisation::NotAuthorisedError, 'You are not allowed to add users to these providers'
    end

    def email_exists?
      ProviderUser.find_by(email_address: wizard.email_address).present?
    end

    def update_user
      existing_user = ProviderUser.find_by(email_address: wizard.email_address)
      existing_user.update(
        email_address: wizard.email_address,
        first_name: wizard.first_name,
        last_name: wizard.last_name,
      )
      update_provider_permissions!(existing_user)
    end

    def create_user
      user = ProviderUser.create(
        email_address: wizard.email_address,
        first_name: wizard.first_name,
        last_name: wizard.last_name,
      )
      create_notification_preferences!(user)
      create_provider_permissions!(user)
      user
    end

    def create_notification_preferences!(user)
      ProviderUserNotificationPreferences.create!(provider_user: user)
    end

    def create_provider_permissions!(user)
      wizard.provider_permissions.each do |provider_id, permission|
        provider_permission = ProviderPermissions.new(
          provider_id: provider_id,
          provider_user_id: user.id,
        )
        permission.fetch('permissions', []).reject(&:blank?).each do |permission_name|
          provider_permission.send("#{permission_name}=".to_sym, true)
        end
        provider_permission.save!
      end
    end

    def update_provider_permissions!(user)
      wizard.provider_permissions.each do |provider_id, permission|
        provider_permission = ProviderPermissions.find_or_initialize_by(
          provider_id: provider_id,
          provider_user_id: user.id,
        )
        ProviderPermissions::VALID_PERMISSIONS.each do |permission_type|
          provider_permission.send(
            "#{permission_type}=",
            permission['permissions'].include?(permission_type.to_s),
          )
        end
        provider_permission.save!
      end
    end
  end
end
