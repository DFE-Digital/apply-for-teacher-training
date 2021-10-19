module SupportInterface
  class SingleProviderUserRemovalsController < ApplicationController
    def new
      @permissions = permissions_to_remove
      @provider = permissions_to_remove.provider
      @user = permissions_to_remove.provider_user
    end

    def create
      flash[:success] = "User no longer has access to #{permissions_to_remove.provider.name}"
      user = permissions_to_remove.provider_user
      provider = permissions_to_remove.provider

      permissions_to_remove.destroy
      ProviderMailer.permissions_removed(user, provider).deliver_later

      redirect_to support_interface_provider_user_path(user)
    end

  private

    def permissions_to_remove
      @_permissions_to_remove = ProviderPermissions.find(params[:provider_permissions_id])
    end
  end
end
