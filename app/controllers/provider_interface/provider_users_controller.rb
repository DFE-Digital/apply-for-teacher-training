module ProviderInterface
  class ProviderUsersController < ProviderInterfaceController
    before_action :requires_provider_add_provider_users_feature_flag, only: %i[new create]

    def index
      @provider_users = ProviderUser.visible_to(current_provider_user)
    end

    def new
      @form = ProviderUserForm.new
      @form.current_provider_user = current_provider_user
    end

    def create
      @form = ProviderUserForm.new(provider_user_params)
      provider_user = @form.build
      render :new && return unless provider_user

      service = InviteProviderUser.new(provider_user: provider_user)
      begin
        service.save_and_invite!
        flash[:success] = 'Provider user invited'
        redirect_to provider_interface_provider_users_path
      rescue DfeSignInApiError => e # show errors from api
        e.errors.each { |error| @form.errors.add(:base, error) }
        render :new
      end
    end

  private

    def provider_user_params
      params.require(:provider_interface_provider_user_form)
            .permit(:email_address, :first_name, :last_name, provider_ids: [])
    end

    def requires_provider_add_provider_users_feature_flag
      raise unless FeatureFlag.active?('provider_add_provider_users')
    end
  end
end
