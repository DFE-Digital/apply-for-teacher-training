module ProviderInterface
  class UserPermissionsController < UsersController
    before_action :redirect_to_edit_if_store_cleared, only: %i[check]

    def edit
      @previous_page_path = previous_page_path
      provider_permissions = @provider_user.provider_permissions.find_by!(provider: @provider)
      @wizard = EditUserPermissionsWizard.from_model(edit_user_permissions_store, provider_permissions)
    end

    def update
      @wizard = EditUserPermissionsWizard.new(edit_user_permissions_store, provider_permissions_params)
      @wizard.save_state!

      redirect_to check_provider_interface_organisation_settings_organisation_user_permissions_path(@provider, @provider_user)
    end

    def check
      @wizard = EditUserPermissionsWizard.new(edit_user_permissions_store)
    end

    def commit
      wizard = EditUserPermissionsWizard.new(edit_user_permissions_store)

      if EditProviderUserPermissions.new(actor: current_provider_user,
                                         provider: @provider,
                                         provider_user: @provider_user,
                                         permissions: wizard.permissions).save
        wizard.clear_state!
        flash[:success] = 'User permissions updated'
        redirect_to provider_interface_organisation_settings_organisation_user_path(@provider, @provider_user)
      end
    end

  private

    def edit_user_permissions_store
      key = "edit_user_permissions_wizard_store_#{current_provider_user.id}_#{@provider.id}_#{@provider_user.id}"
      WizardStateStores::RedisStore.new(key:)
    end

    def provider_permissions_params
      params.require(:provider_interface_edit_user_permissions_wizard).permit(permissions: [])
    end

    def previous_page_path
      if params[:checking_answers] == 'true'
        check_provider_interface_organisation_settings_organisation_user_permissions_path(@provider, @provider_user)
      else
        provider_interface_organisation_settings_organisation_user_path(@provider, @provider_user)
      end
    end

    def redirect_to_edit_if_store_cleared
      return if edit_user_permissions_store.read.present?

      redirect_to edit_provider_interface_organisation_settings_organisation_user_permissions_path(@provider, @provider_user)
    end
  end
end
