module ProviderInterface
  class RemoveUserFromProvider
    include ImpersonationAuditHelper

    attr_reader :current_provider_user, :provider, :user_to_remove

    def initialize(current_provider_user:, provider:, user_to_remove:)
      @current_provider_user = current_provider_user
      @provider = provider
      @user_to_remove = user_to_remove
    end

    def call!
      audit(current_provider_user) do
        assert_current_user_can_manage_users!

        provider_permission = user_to_remove.provider_permissions.find_by!(provider: provider)
        provider_permission.audit_comment = 'User was deleted'
        provider_permission.destroy!
      end
    end

  private

    def assert_current_user_can_manage_users!
      return if current_provider_user.authorisation.can_manage_users_for?(provider: provider)

      raise ProviderInterface::AccessDenied.new({
        permission: 'manage_users',
        training_provider: provider,
        provider_user: current_provider_user,
      }), 'manage_users required'
    end
  end
end
