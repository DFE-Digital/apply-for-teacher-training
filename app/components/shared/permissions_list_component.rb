class PermissionsListComponent < ViewComponent::Base
  attr_reader :user_is_viewing_their_own_permissions, :permission_model

  def initialize(permission_model, user_is_viewing_their_own_permissions: false)
    @permission_model = permission_model
    @user_is_viewing_their_own_permissions = user_is_viewing_their_own_permissions
  end
end
