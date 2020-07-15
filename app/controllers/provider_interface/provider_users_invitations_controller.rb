module ProviderInterface
  class ProviderUsersInvitationsController < ProviderInterfaceController
    before_action :require_feature_flag
    before_action :redirect_unless_permitted_to_manage_users

    def edit_details
      @wizard = ProviderUserInvitationWizard.new(session, current_step: 'details')
      @wizard.save_state!
    end

    def update_details
      @wizard = ProviderUserInvitationWizard.new(session, wizard_params)

      if @wizard.valid_for_current_step?
        @wizard.save_state!
        redirect_to next_redirect(@wizard)
      else
        render :edit_details
      end
    end

    def edit_providers
      @wizard = ProviderUserInvitationWizard.new(session, current_step: 'providers')
      @wizard.save_state!

      @available_providers = current_provider_user.providers
    end

    def update_providers
      @wizard = ProviderUserInvitationWizard.new(session, wizard_params)
      @available_providers = current_provider_user.providers

      if @wizard.valid_for_current_step?
        @wizard.save_state!
        redirect_to next_redirect(@wizard)
      else
        render :edit_providers
      end
    end

    def edit_permissions
      @wizard = ProviderUserInvitationWizard.new(session, current_step: 'permissions')
      @wizard.save_state!

      @permissions_form = ProviderPermissionsForm.new(@wizard.permissions_for(params[:provider_id]))
    end

    def update_permissions
      @wizard = ProviderUserInvitationWizard.new(session, wizard_params)
      @wizard.save_state!

      redirect_to next_redirect(@wizard)
    end

    def check
      @wizard = ProviderUserInvitationWizard.new(session, current_step: 'check')
      @wizard.save_state!
    end

    def commit
      @wizard = ProviderUserInvitationWizard.new(session)
      # wizard.save!
      @wizard.clear_state!

      flash[:success] = 'User successfully invited'
      redirect_to provider_interface_provider_users_path
    end

    def next_redirect(wizard)
      step, provider_id = wizard.next_step

      {
        check: { action: :check },
        providers: { action: :edit_providers },
        permissions: { action: :edit_permissions, provider_id: provider_id },
      }.fetch(step)
    end

    def wizard_params
      params.require(:provider_interface_provider_user_invitation_wizard)
        .permit(:change_answer, :first_name, :last_name, :email_address, :first_name, providers: [], provider_permissions: {})
    end

  private

    def require_feature_flag
      render_404 unless FeatureFlag.active?(:providers_can_manage_users_and_permissions)
    end

    def redirect_unless_permitted_to_manage_users
      can_manage_users = ProviderPermissions.exists?(provider_user: current_provider_user, manage_users: true)
      render_404 unless can_manage_users
    end
  end
end
