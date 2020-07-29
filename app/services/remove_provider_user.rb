class RemoveProviderUser
  attr_reader :current_provider_user, :user_to_remove

  def initialize(current_provider_user:, user_to_remove:)
    @current_provider_user = current_provider_user
    @user_to_remove = user_to_remove
  end

  # Removes associations to providers common to the managing user
  # and the user we're editing/removing.
  def call!
    managed_providers = current_provider_user.authorisation.providers_that_actor_can_manage_users_for

    user_to_remove.provider_permissions.includes(:provider).each do |provider_permission|
      next unless provider_permission.provider.in?(managed_providers)

      provider_permission.audit_comment = 'User was deleted'
      provider_permission.destroy!
    end
  end
end
