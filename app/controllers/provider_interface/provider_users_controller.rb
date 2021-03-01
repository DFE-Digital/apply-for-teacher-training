module ProviderInterface
  class ProviderUsersController < ProviderInterfaceController
    before_action :require_manage_users_permission!
    before_action :find_provider_user, except: %i[index]

    def index
      users = ProviderUser.includes(:providers).visible_to(current_provider_user)
      providers = Provider.with_users_manageable_by(current_provider_user).order(:name)
      @provider_users_with_providers = {}
      users.each { |u| @provider_users_with_providers[u] = providers & u.providers }
    end

    def show
      @possible_permissions = ProviderPermissions.possible_permissions(
        current_provider_user: current_provider_user,
        provider_user: @provider_user,
      )
    end

    def edit_permissions
      provider_permissions = find_provider_permissions_model!
      assert_current_user_can_manage_users_for provider_permissions.provider

      @form = ProviderInterface::ProviderUserEditPermissionsForm.build_from_model provider_permissions
      if @form.invalid?
        redirect_to provider_interface_provider_user_path(@provider_user)
      end
    end

    def update_permissions
      provider_permissions = find_provider_permissions_model!
      assert_current_user_can_manage_users_for provider_permissions.provider

      @form = ProviderInterface::ProviderUserEditPermissionsForm.build_from_model provider_permissions
      @form.update_from_params provider_update_permissions_params

      if @form.save
        flash[:success] = 'User’s permissions successfully updated'
        redirect_to provider_interface_provider_user_path(@provider_user)
      else
        render action: :edit_permissions
      end
    end

    def confirm_remove; end

    def remove
      service = RemoveProviderUser.new(
        current_provider_user: current_provider_user,
        user_to_remove: @provider_user,
      )

      flash[:success] = 'User’s account successfully deleted' if service.call!
      redirect_to provider_interface_provider_users_path
    end

    def edit_providers
      @form = ProviderUserProvidersForm.from_provider_user(
        provider_user: @provider_user,
        current_provider_user: current_provider_user,
      )
    end

    def update_providers
      @form = ProviderUserProvidersForm.new(
        provider_user: @provider_user,
        current_provider_user: current_provider_user,
        provider_ids: params.dig(:provider_interface_provider_user_providers_form, :provider_ids),
      )

      if @form.save
        flash[:success] = 'User’s access successfully updated'
        redirect_to provider_interface_provider_user_path(@provider_user)
      else
        render :edit_providers
      end
    end

  private

    def provider_update_permissions_params
      params.require(:provider_interface_provider_user_edit_permissions_form)
            .permit(provider_permissions: {})
    end

    def require_manage_users_permission!
      render_403 unless current_provider_user.authorisation.can_manage_users_for_at_least_one_provider?
    end

    def assert_current_user_can_manage_users_for(provider)
      access_denied_for_provider(provider) unless current_provider_user.authorisation.can_manage_users_for?(provider: provider)
    end

    def access_denied_for_provider(provider)
      raise ProviderInterface::AccessDenied.new({
        permission: 'manage_users',
        training_provider: provider,
        ratifying_provider: provider,
        provider_user: current_provider_user,
      }), 'manage_users required'
    end

    def find_provider_user
      @provider_user = ProviderUser
        .visible_to(current_provider_user)
        .find(params[:provider_user_id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    def find_provider_permissions_model!
      ProviderPermissions.find_by!(
        provider_user: @provider_user,
        provider: Provider.find(params[:provider_id]),
      )
    end
  end
end
