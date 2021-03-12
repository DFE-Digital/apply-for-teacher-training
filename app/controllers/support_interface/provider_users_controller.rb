module SupportInterface
  class ProviderUsersController < SupportInterfaceController
    def index
      @provider_users = ProviderUser
        .includes(providers: %i[training_provider_permissions ratifying_provider_permissions])
        .page(params[:page] || 1).per(30)

      @provider_users = scope_by_use_of_service

      if params[:q]
        @provider_users = @provider_users.where("CONCAT(first_name, ' ', last_name, ' ', email_address) ILIKE ?", "%#{params[:q]}%")
      end

      @filter = SupportInterface::ProviderUsersFilter.new(params: params)
    end

    def show
      @provider_user = ProviderUser.find(params[:id])
    end

    def new
      @form = ProviderUserForm.new
    end

    def create
      @form = ProviderUserForm.new(provider_user_params.merge(provider_permissions: provider_permissions_params))
      provider_user = @form.build
      service = SaveAndInviteProviderUser.new(
        form: @form,
        save_service: SaveProviderUser.new(
          provider_user: provider_user,
          provider_permissions: @form.provider_permissions,
        ),
        invite_service: InviteProviderUser.new(provider_user: provider_user),
      )

      render :new and return unless service.call

      flash[:success] = 'Provider user created'
      redirect_to support_interface_provider_users_path
    end

    def edit
      provider_user = ProviderUser.find(params[:id])
      @form = ProviderUserForm.from_provider_user(provider_user)
    end

    def update
      provider_user = ProviderUser.find(params[:id])

      @form = ProviderUserForm.new(
        provider_user: provider_user,
        provider_permissions: provider_permissions_params,
      )

      service = SaveProviderUser.new(
        provider_user: provider_user,
        provider_permissions: @form.provider_permissions,
        deselected_provider_permissions: @form.deselected_provider_permissions,
      )

      if service.call!
        flash[:success] = 'Provider user updated'
        redirect_to support_interface_provider_user_path(provider_user)
      else
        render :edit
      end
    end

    def audits
      @provider_user = ProviderUser.find(params[:provider_user_id])
    end

    def toggle_notifications
      provider_user = ProviderUser.find(params[:provider_user_id])

      SaveProviderUserNotificationPreferences
        .new(provider_user: provider_user)
        .backfill_notification_preferences!(send_notifications: !provider_user.send_notifications)

      flash[:success] = 'Provider user updated'
      redirect_to support_interface_provider_user_path(provider_user)
    end

    def update_notifications
      render_404 unless FeatureFlag.active?(:configurable_provider_notifications)

      provider_user = ProviderUser.find(params[:provider_user_id])
      notification_preferences = provider_user.notification_preferences

      if notification_preferences.update!(notification_preferences_params)
        flash[:success] = 'Provider user notifications updated'
        redirect_to support_interface_provider_user_path(provider_user)
      end
    end

    def impersonate
      @provider_user = ProviderUser.find(params[:provider_user_id])
      dfe_sign_in_user.begin_impersonation! session, @provider_user
      redirect_to support_interface_provider_user_path(@provider_user)
    end

    def end_impersonation
      if (impersonated_user = current_support_user.impersonated_provider_user)
        dfe_sign_in_user.end_impersonation! session
        redirect_to support_interface_provider_user_path(impersonated_user)
      else
        flash[:success] = 'No active provider user impersonation to stop'
        redirect_to support_interface_provider_users_path
      end
    end

  private

    def scope_by_use_of_service
      if params[:use_of_service] == %w[never_signed_in]
        @provider_users.where(last_signed_in_at: nil)
      elsif params[:use_of_service] == %w[has_signed_in]
        @provider_users.where.not(last_signed_in_at: nil)
      else
        @provider_users
      end
    end

    def provider_user_params
      params.require(:support_interface_provider_user_form)
        .permit(:email_address, :first_name, :last_name)
    end

    def provider_permissions_params
      params.require(:support_interface_provider_user_form)
            .permit(provider_permissions_forms: {})
            .fetch(:provider_permissions_forms, {})
            .to_h
    end

    def notification_preferences_params
      return ActionController::Parameters.new unless params.key?(:provider_user_notification_preferences)

      params.require(:provider_user_notification_preferences)
        .permit(ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES)
    end
  end
end
