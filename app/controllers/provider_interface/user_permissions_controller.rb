module ProviderInterface
  class UserPermissionsController < UsersController
    def edit
      @previous_page_path = provider_interface_organisation_settings_organisation_user_path(@provider, @provider_user)
      provider_permissions = @provider_user.provider_permissions.find_by!(provider: @provider)
      @wizard = EditUserPermissionsWizard.from_model(edit_user_permissions_store, provider_permissions)
    end

  private

    def edit_user_permissions_store
      key = "edit_user_permissions_wizard_store_#{current_provider_user.id}_#{@provider.id}_#{@provider_user.id}"
      WizardStateStores::RedisStore.new(key: key)
    end
  end
end
