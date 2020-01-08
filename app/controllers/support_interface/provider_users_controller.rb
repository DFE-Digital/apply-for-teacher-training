module SupportInterface
  class ProviderUsersController < SupportInterfaceController
    def index
      @provider_users = ProviderUser.all
    end

    def new
      @form = ProviderUserForm.new(available_providers: Provider.all)
    end

    def create
      @form = ProviderUserForm.new(provider_user_params.merge(available_providers: Provider.all))

      if @form.save
        flash[:success] = 'Provider user created'
        redirect_to support_interface_provider_users_path
      else
        render :new
      end
    end

  private

    def provider_user_params
      params.require(:support_interface_provider_user_form).permit(:email_address, :dfe_sign_in_uid, provider_ids: [])
    end
  end
end
