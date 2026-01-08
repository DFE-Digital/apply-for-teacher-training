module SupportInterface
  class ProviderUsersController < SupportInterfaceController
    PAGY_PER_PAGE = 30

    def index
      provider_users_scope = ProviderUser
        .includes(providers: %i[training_provider_permissions ratifying_provider_permissions])

      @filter = SupportInterface::ProviderUsersFilter.new(params:)

      provider_users_scope = scope_by_use_of_service(provider_users_scope, @filter)
      provider_users_scope = scope_by_search_term(provider_users_scope, @filter)

      @pagy, @provider_users = pagy(provider_users_scope, limit: PAGY_PER_PAGE)
    end

    def show
      @provider_user = ProviderUser.find(params[:id])
    end

    def audits
      @provider_user = ProviderUser.find(params[:provider_user_id])
    end

    def impersonate
      @provider_user = ProviderUser.find(params[:provider_user_id])
      if FeatureFlag.active?(:dsi_stateful_session)
        Current.support_session.update!(impersonated_provider_user_id: @provider_user.id)
        cookies.signed.permanent[:impersonated_provider_user_id] = {
          value: @provider_user.id,
          httponly: true,
          same_site: :lax,
          secure: !Rails.env.test? && (HostingEnvironment.production? || HostingEnvironment.sandbox_mode? || HostingEnvironment.qa?),
        }
      else
        dfe_sign_in_user.begin_impersonation! session, @provider_user
      end

      redirect_to support_interface_provider_user_path(@provider_user)
    end

    def end_impersonation
      impersonated_user = if FeatureFlag.active?(:dsi_stateful_session)
                            Current.support_session.impersonated_provider_user
                          else
                            current_support_user.impersonated_provider_user
                          end

      if impersonated_user
        if FeatureFlag.active?(:dsi_stateful_session)
          Current.support_session.update(impersonated_provider_user_id: nil)
          cookies.delete(:impersonated_provider_user_id)
        else
          dfe_sign_in_user.end_impersonation! session
        end
        redirect_to support_interface_provider_user_path(impersonated_user)
      else
        flash[:success] = 'No active provider user impersonation to stop'
        redirect_to support_interface_provider_users_path
      end
    end

  private

    def scope_by_use_of_service(scope, filter)
      case filter.applied_filters[:use_of_service]
      when 'never_signed_in'
        scope.where(last_signed_in_at: nil)
      when 'has_signed_in'
        scope.where.not(last_signed_in_at: nil)
      else
        scope
      end
    end

    def scope_by_search_term(scope, filter)
      return scope if filter.applied_filters[:q].blank?

      if filter.applied_filters[:q] =~ /^\d+$/
        scope.where(id: filter.applied_filters[:q])
      else
        scope.where("CONCAT(first_name, ' ', last_name, ' ', email_address) ILIKE ?", "%#{filter.applied_filters[:q]}%")
      end
    end
  end
end
