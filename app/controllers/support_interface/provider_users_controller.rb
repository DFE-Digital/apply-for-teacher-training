module SupportInterface
  class ProviderUsersController < SupportInterfaceController
    def index
      @provider_users = ProviderUser
        .includes(providers: %i[training_provider_permissions ratifying_provider_permissions])
        .page(params[:page] || 1).per(30)

      @provider_users = scope_by_use_of_service
      @provider_users = scope_by_search_term

      @filter = SupportInterface::ProviderUsersFilter.new(params: params)
    end

    def show
      @provider_user = ProviderUser.find(params[:id])
    end

    def audits
      @provider_user = ProviderUser.find(params[:provider_user_id])
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

    def scope_by_search_term
      return @provider_users if params[:q].blank?

      if params[:q] =~ /^\d+$/
        @provider_users.where(id: params[:q])
      else
        @provider_users.where("CONCAT(first_name, ' ', last_name, ' ', email_address) ILIKE ?", "%#{params[:q]}%")
      end
    end
  end
end
