module ProviderInterface
  class EditProviderUserPermissions
    include ImpersonationAuditHelper

    attr_accessor :actor, :provider, :provider_user, :permissions

    def initialize(actor:, provider:, provider_user:, permissions:)
      @actor = actor
      @provider = provider
      @provider_user = provider_user
      @permissions = permissions.reject(&:empty?)
    end

    def save
      audit(actor) do
        ActiveRecord::Base.transaction do
          assert_actor_can_manage_users_for_provider!
          update_provider_permissions!
        end

        send_permissions_updated_email
      end
    end

  private

    def assert_actor_can_manage_users_for_provider!
      return if actor.authorisation.can_manage_users_for?(provider: provider)

      raise ProviderInterface::AccessDenied.new({
        permission: 'manage_users',
        training_provider: provider,
        provider_user: actor,
      }), 'manage_users required'
    end

    def update_provider_permissions!
      ProviderPermissions::VALID_PERMISSIONS.each do |permission|
        provider_permissions.send("#{permission}=", permissions.include?(permission.to_s))
      end
      provider_permissions.save!
    end

    def send_permissions_updated_email
      ProviderMailer.permissions_updated(provider_user, provider, permissions, actor).deliver_later
    end

    def provider_permissions
      @provider_permissions ||= provider_user.provider_permissions.find_by!(provider: provider)
    end
  end
end
