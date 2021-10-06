module ProviderInterface
  class RemoveUserFromProvider
    include ImpersonationAuditHelper

    attr_reader :actor, :provider, :user_to_remove

    def initialize(actor:, provider:, user_to_remove:)
      @actor = actor
      @provider = provider
      @user_to_remove = user_to_remove
    end

    def call!
      audit(actor) do
        assert_current_user_can_manage_users!

        provider_permission = user_to_remove.provider_permissions.find_by!(provider: provider)
        provider_permission.audit_comment = 'User was deleted'
        provider_permission.destroy!
        send_permissions_removed_email
      end
    end

  private

    def assert_current_user_can_manage_users!
      return if actor.authorisation.can_manage_users_for?(provider: provider)

      raise ProviderInterface::AccessDenied.new({
        permission: 'manage_users',
        training_provider: provider,
        provider_user: actor,
      }), 'manage_users required'
    end

    def send_permissions_removed_email
      ProviderMailer.permissions_removed(user_to_remove, provider, actor)
    end
  end
end
