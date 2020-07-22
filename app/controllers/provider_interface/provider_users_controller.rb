module ProviderInterface
  class ProviderUsersController < ProviderInterfaceController
    before_action :require_feature_flag!
    before_action :require_manage_user_permission!

    def index
      users = ProviderUser.includes(:providers).visible_to(current_provider_user)
      providers = Provider.with_users_manageable_by(current_provider_user).order(:name)
      @provider_users_with_providers = {}
      users.each { |u| @provider_users_with_providers[u] = providers & u.providers }
    end

    def show
      @provider_user = find_provider_user

      @possible_permissions = ProviderPermissions.possible_permissions(
        current_provider_user: current_provider_user,
        provider_user: @provider_user,
      )
    end

    def new
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

      flash[:success] = 'User successfully invited'
      redirect_to provider_interface_provider_users_path
    end

    def edit_providers
      provider_user = find_provider_user

      @form = ProviderUserForm.from_provider_user(provider_user)
      @form.current_provider_user = current_provider_user
    end

    def update_providers
      provider_user = find_provider_user

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

    def confirm_remove
      @provider_user = find_provider_user
    end

    def remove
      @provider_user = find_provider_user
      service = RemoveProviderUser.new(
        current_provider_user: current_provider_user,
        user_to_remove: @provider_user,
      )

      flash[:success] = 'User’s account successfully deleted' if service.call!
      redirect_to provider_interface_provider_users_path
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

    def require_feature_flag!
      render_404 unless FeatureFlag.active?(:providers_can_manage_users_and_permissions)
    end

    def require_manage_user_permission!
      render_404 unless current_provider_user.authorisation.can_manage_users_for_at_least_one_provider?
    end

    def find_provider_user
      ProviderUser
        .visible_to(current_provider_user)
        .find(params[:provider_user_id] || params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
end
