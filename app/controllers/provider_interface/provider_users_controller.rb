module ProviderInterface
  class ProviderUsersController < ProviderInterfaceController
    before_action :requires_provider_add_provider_users_feature_flag
    before_action :redirect_unless_permitted_to_manage_users

    def index
      @provider_users = ProviderUser.visible_to(current_provider_user)
    end

    def show
      @provider_user = ProviderUser.visible_to(current_provider_user).find_by(id: params[:id])

      redirect_to(action: :index) and return unless @provider_user

      @possible_permissions = ProviderPermissions.possible_permissions(
        current_provider_user: current_provider_user,
        provider_user: @provider_user,
      )
    end

    def new
      unless current_provider_user.can_manage_users?
        flash[:warning] = 'You need specific permissions to manage other providers.'
        return redirect_to provider_interface_provider_users_path
      end

      @form = ProviderUserForm.new(current_provider_user: current_provider_user)
    end

    def create
      @form = ProviderUserForm.new(
        provider_user_params.merge(
          current_provider_user: current_provider_user,
          provider_permissions: provider_permissions_params,
        ),
      )
      provider_user = @form.build
      service = SaveAndInviteProviderUser.new(
        form: @form,
        save_service: SaveProviderUser.new(
          provider_user: provider_user,
          provider_permissions: @form.provider_permissions,
        ),
        invite_service: InviteProviderUser.new(provider_user: provider_user),
        new_user: @form.existing_provider_user.blank?,
      )

      render :new and return unless service.call

      flash[:success] = 'Provider user invited'
      redirect_to provider_interface_provider_users_path
    end

    def edit_providers
      provider_user = ProviderUser.visible_to(current_provider_user).find_by(id: params[:provider_user_id])
      @form = ProviderUserForm.from_provider_user(provider_user)
      @form.current_provider_user = current_provider_user
    end

    def update_providers
      provider_user = ProviderUser
        .visible_to(current_provider_user)
        .find_by(id: params[:provider_user_id])

      @form = ProviderUserForm.new(
        provider_user: provider_user,
        current_provider_user: current_provider_user,
        provider_permissions: provider_permissions_params,
      )

      service = SaveProviderUser.new(
        provider_user: provider_user,
        provider_permissions: @form.provider_permissions,
        deselected_provider_permissions: @form.deselected_provider_permissions,
      )

      render :edit_providers and return unless @form.valid? && service.call!

      flash[:success] = 'Providers updated'
      redirect_to provider_interface_provider_user_path(provider_user)
    end

  private

    def provider_user_params
      params.require(:provider_interface_provider_user_form)
            .permit(:email_address, :first_name, :last_name)
    end

    def provider_permissions_params
      params.require(:provider_interface_provider_user_form)
            .permit(provider_permissions_forms: {})
            .fetch(:provider_permissions_forms, {})
            .to_h
    end

    def requires_provider_add_provider_users_feature_flag
      raise unless FeatureFlag.active?('provider_add_provider_users')
    end

    def redirect_unless_permitted_to_manage_users
      can_manage_users = ProviderPermissions.exists?(provider_user: current_provider_user, manage_users: true)
      redirect_to root_path, warning: 'You do not have sufficient permissions to manage other users' unless can_manage_users
    end
  end
end
