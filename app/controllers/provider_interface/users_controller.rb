module ProviderInterface
  class UsersController < ProviderInterfaceController
    before_action :set_provider
    before_action :set_provider_user, except: :index
    before_action :assert_can_manage_users!, except: %i[index show]

    def index
      @current_user_can_manage_users = current_user_can_manage_users
    end

    def show
      @current_user_can_manage_users = current_user_can_manage_users
    end

    def confirm_destroy; end

    def destroy
      RemoveUserFromProvider.new(actor: current_provider_user, provider: @provider, user_to_remove: @provider_user).call!

      flash[:success] = 'User deleted'
      redirect_to provider_interface_organisation_settings_organisation_users_path(@provider)
    end

  private

    def set_provider
      @provider = current_provider_user.providers.find(params[:organisation_id])
    end

    def set_provider_user
      @provider_user = @provider.provider_users.find(params[:id])
    end

    def assert_can_manage_users!
      render_403 unless current_user_can_manage_users
    end

    def current_user_can_manage_users
      current_provider_user.authorisation.can_manage_users_for?(provider: @provider)
    end
  end
end
