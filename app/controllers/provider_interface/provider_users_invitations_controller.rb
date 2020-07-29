module ProviderInterface
  class ProviderUsersInvitationsController < ProviderInterfaceController
    before_action :require_feature_flag!
    before_action :require_manage_user_permission!

    def edit_details
      @wizard = wizard_for(current_step: 'details')
      @wizard.save_state!
    end

    def update_details
      @wizard = wizard_for(details_params.merge(current_step: 'details'))

      if @wizard.valid_for_current_step?
        @wizard.save_state!
        redirect_to next_redirect
      else
        render :edit_details
      end
    end

    def edit_providers
      @wizard = wizard_for(current_step: 'providers')
      @wizard.save_state!

      @available_providers = current_provider_user.provider_permissions
                                                  .manage_users
                                                  .includes(:provider)
                                                  .map(&:provider)
    end

    def update_providers
      @wizard = wizard_for(providers_params.merge(current_step: 'providers'))
      @available_providers = current_provider_user.providers

      if @wizard.valid_for_current_step?
        @wizard.save_state!
        redirect_to next_redirect
      else
        render :edit_providers
      end
    end

    def edit_permissions
      @wizard = wizard_for(current_step: 'permissions', current_provider_id: params[:provider_id])
      @wizard.save_state!

      setup_permission_form
    end

    def update_permissions
      @wizard = wizard_for(permissions_params.merge(current_step: 'permissions', current_provider_id: params[:provider_id]))

      if @wizard.valid_for_current_step?
        @wizard.save_state!
        redirect_to next_redirect
      else
        setup_permission_form
        render :edit_permissions
      end
    end

    def check
      @wizard = wizard_for(current_step: 'check')
      @wizard.save_state!
    end

    def commit
      @wizard = wizard_for({})

      save_service = ProviderInterface::SaveProviderUserService.new(
        actor: current_provider_user,
        wizard: @wizard,
      )
      service = SaveAndInviteProviderUser.new(
        form: @wizard,
        save_service: save_service,
        invite_service: InviteProviderUser.new(provider_user: @wizard.email_address),
        new_user: @wizard.new_user?,
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

    def wizard_for(options)
      options[:checking_answers] = true if params[:checking_answers] == 'true'
      ProviderUserInvitationWizard.new(session, options)
    end

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

    def require_feature_flag!
      render_404 unless FeatureFlag.active?(:providers_can_manage_users_and_permissions)
    end

    def require_manage_user_permission!
      render_404 unless current_provider_user.authorisation.can_manage_users_for_at_least_one_provider?
    end

    def setup_permission_form
      @provider = Provider.find(params[:provider_id])

      @permissions_form = ProviderInterface::ProviderUserInvitationWizard::PermissionsForm.new(
        provider_id: @provider.id,
        permissions: @wizard.permissions_for_provider(@provider.id),
      )
    end
  end
end
