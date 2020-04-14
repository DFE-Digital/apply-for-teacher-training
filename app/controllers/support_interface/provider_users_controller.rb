module SupportInterface
  class ProviderUsersController < SupportInterfaceController
    def index
      @provider_users = ProviderUser.includes(:providers).all
    end

    def new
      @form = ProviderUserForm.new
    end

    def create
      @form = ProviderUserForm.new(provider_user_params)
      provider_user = @form.build

      service = SaveAndInviteProviderUser.new(
        form: @form,
        save_service: SaveProviderUser.new(provider_user: provider_user, permissions: permissions_params),
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
      @form = ProviderUserForm.from_provider_user(provider_user)
      @form.assign_attributes provider_user_params

      if @form.save
        flash[:success] = 'Provider user updated'
        redirect_to edit_support_interface_provider_user_path(provider_user)
      else
        render :edit
      end
    end

  private

    def provider_user_params
      params.require(:support_interface_provider_user_form)
        .permit(:email_address, :first_name, :last_name, provider_ids: [], permissions: { manage_users: [] })
    end

    def permissions_params
      provider_user_params.fetch(:permissions, {})
    end
  end
end
