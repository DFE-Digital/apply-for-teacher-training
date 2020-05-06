class RemoveProviderUser
  attr_reader :current_provider_user, :user_to_remove

  def initialize(current_provider_user:, user_to_remove:)
    @current_provider_user = current_provider_user
    @user_to_remove = user_to_remove
  end

  # Removes associations to providers common to the managing user
  # and the user we're editing/removing.
  def call!
    managed_providers = current_provider_user.provider_permissions.manage_users.includes(:provider).map(&:provider)
    shared_providers = managed_providers & user_to_remove.providers
    user_to_remove.providers -= shared_providers
    user_to_remove.save!
  end
end
