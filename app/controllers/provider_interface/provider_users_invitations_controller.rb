module ProviderInterface
  class ProviderUsersInvitationsController < ProviderInterfaceController
    before_action :require_feature_flag
    before_action :redirect_unless_permitted_to_manage_users

    def edit_details
      @wizard = ProviderUserInvitationWizard.new(session, current_step: 'details')
      @wizard.save_state!
    end

    def update_details
      @wizard = ProviderUserInvitationWizard.new(session, details_params.merge(current_step: 'details'))

      if @wizard.valid_for_current_step?
        @wizard.save_state!
        redirect_to next_redirect
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
      @wizard = ProviderUserInvitationWizard.new(session, providers_params.merge(current_step: 'providers'))
      @available_providers = current_provider_user.providers

      if @wizard.valid_for_current_step?
        @wizard.save_state!
        redirect_to next_redirect
      else
        render :edit_providers
      end
    end

    def edit_permissions
      @wizard = ProviderUserInvitationWizard.new(session, current_step: 'permissions', current_provider_id: params[:provider_id])
      @wizard.save_state!

      @permissions_form = ProviderUserPermissionsForm.new(@wizard.permissions_for(params[:provider_id]))
    end

    def update_permissions
      @wizard = ProviderUserInvitationWizard.new(session, permissions_params.merge(current_step: 'permissions', current_provider_id: params[:provider_id]))
      @wizard.save_state!

      redirect_to next_redirect
    end

    def check
      @wizard = ProviderUserInvitationWizard.new(session, current_step: 'check')
      @wizard.save_state!
    end

    def commit
      @wizard = ProviderUserInvitationWizard.new(session)
      service = SaveAndInviteProviderUser.new(
        form: @wizard,
        save_service: ProviderInterface::SaveProviderUserService.new(@wizard),
        invite_service: InviteProviderUser.new(provider_user: nil),
        new_user: false,
      )
      render :check and return unless service.call

      @wizard.clear_state!

      flash[:success] = 'User successfully invited'
      redirect_to provider_interface_provider_users_path
    end

    def next_redirect
      step, provider_id = @wizard.next_step

      path_for(step, provider_id)
    end

    def previous_page
      step, provider_id = @wizard.previous_step

      path_for(step, provider_id)
    end
    helper_method :previous_page

  private

    def path_for(step, provider_id)
      {
        check: { action: :check },
        providers: { action: :edit_providers },
        permissions: { action: :edit_permissions, provider_id: provider_id },
        details: { action: :edit_details },
        index: provider_interface_provider_users_path,
      }.fetch(step)
    end

    def details_params
      params.require(:provider_interface_provider_user_invitation_wizard)
        .permit(:first_name, :last_name, :email_address)
    end

    def providers_params
      params.require(:provider_interface_provider_user_invitation_wizard)
        .permit(providers: [])
    end

    def permissions_params
      params.require(:provider_interface_provider_user_invitation_wizard)
        .permit(provider_permissions: {})
    end

    def require_feature_flag
      render_404 unless FeatureFlag.active?(:providers_can_manage_users_and_permissions)
    end

    def redirect_unless_permitted_to_manage_users
      can_manage_users = ProviderPermissions.exists?(provider_user: current_provider_user, manage_users: true)
      render_404 unless can_manage_users
    end
  end
end
