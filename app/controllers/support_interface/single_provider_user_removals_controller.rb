module SupportInterface
  class SingleProviderUserRemovalsController < SupportInterfaceController
    before_action :authorize_support_user

    def new
      @permissions = permissions_to_remove
      @provider = permissions_to_remove.provider
      @user = permissions_to_remove.provider_user
    end

    def create
      flash[:success] = "User no longer has access to #{permissions_to_remove.provider.name}"
      user = permissions_to_remove.provider_user
      SupportInterface::RemoveUserFromProvider.new(permissions_to_remove:).call!

      redirect_to support_interface_provider_user_path(user)
    end

  private

    def permissions_to_remove
      @_permissions_to_remove = ProviderPermissions.find(params.expect(:provider_permissions_id))
    end

    def authorize_support_user
      authorize(permissions_to_remove.provider_user, :edit?, policy_class: SupportInterface::ProviderUserPolicy)
    end
  end
end
