module SupportInterface
  class SingleProviderUsersController < SupportInterfaceController
    def new
      @provider = Provider.find(provider_id_param)
      @form = CreateSingleProviderUserForm.new(provider_id: provider_id_param)
    end

    def edit
      provider_user = ProviderUser.find(params[:provider_user_id])
      @form = EditSingleProviderUserForm.new(provider_user: provider_user)
    end

    def create
      @form = CreateSingleProviderUserForm.new(
        provider_user_params
          .merge(provider_permissions: create_provider_permissions_params)
          .merge(provider_id: provider_id_param),
      )

      @provider = Provider.find(provider_id_param)

      provider_user = @form.build
      service = SaveAndInviteProviderUser.new(
        form: @form,
        save_service: SaveProviderUser.new(
          provider_user: provider_user,
          provider_permissions: [@form.provider_permissions],
        ),
        invite_service: InviteProviderUser.new(provider_user: provider_user),
      )

      render :new and return unless service.call

      flash[:success] = "User #{provider_user.first_name} #{provider_user.last_name} added"
      redirect_to support_interface_provider_user_list_path
    end

    def update
      provider_user = ProviderUser.find(params[:provider_user_id])

      @form = EditSingleProviderUserForm.new(
        provider_user: provider_user,
        provider_permissions: edit_providers_permissions_params,
        provider_id: provider_id_param,
      )

      service = SaveProviderUser.new(
        provider_user: provider_user,
        provider_permissions: @form.provider_permissions,
        deselected_provider_permissions: @form.deselected_provider_permissions,
      )

      if service.call!
        flash[:success] = "User #{provider_user.first_name} #{provider_user.last_name} updated"
        redirect_to support_interface_provider_user_path(provider_user)
      else
        render :edit
      end
    end

  private

    def provider_id_param
      params[:provider_id].to_i
    end

    def provider_user_params
      params.require(:support_interface_create_single_provider_user_form)
            .permit(:email_address, :first_name, :last_name, :provider_id)
    end

    def create_provider_permissions_params
      params.require(:support_interface_create_single_provider_user_form)
            .permit(provider_permissions_form: {})
            .fetch(:provider_permissions_form, {})
            .to_h
    end

    def edit_providers_permissions_params
      params.require(:support_interface_edit_single_provider_user_form)
            .permit(provider_permissions_forms: {})
            .fetch(:provider_permissions_forms, {})
            .to_h
    end
  end
end
