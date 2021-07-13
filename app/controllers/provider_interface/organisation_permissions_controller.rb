module ProviderInterface
  class OrganisationPermissionsController < ProviderInterfaceController
    before_action :require_accredited_provider_setting_permissions_flag
    before_action :set_up_relationship_objects, except: %i[index show]
    before_action :provider_id_and_permission_check, except: %i[index show]

    # For now, list providers; next version will list relationships for a provider
    def index
      @manageable_providers = manageable_providers
    end

    # This action will be dropped once #index lists relationships.
    # Its temporary nature and reliance of provider ids, rather than relationship ids,
    # is why it gets it own 403/404 checks and responses.
    def show
      @provider = current_provider_user.providers.find(params[:id])
      render_403 unless current_provider_user.authorisation.can_manage_organisation?(provider: @provider)

      @provider_relationships = ProviderRelationshipPermissions.all_relationships_for_providers([@provider]).where.not(setup_at: nil)
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    def edit; end

    def update
      if @relationship.update(new_relationship_permissions)
        flash[:success] = 'Organisation permissions successfully updated'
        redirect_to provider_interface_organisation_settings_organisation_permission_path(Provider.find(params[:provider_id]))
      else
        track_validation_error(@relationship)
        render :edit
      end
    end

  private

    def manageable_providers
      @_manageable_providers ||= current_provider_user.authorisation.providers_that_actor_can_manage_organisations_for(with_set_up_permissions: true)
    end

    def permissions_params
      return {} unless params.key?(:provider_relationship_permissions)

      params.require(:provider_relationship_permissions)
            .permit(training_provider_can_make_decisions: [],
                    ratifying_provider_can_make_decisions: [],
                    training_provider_can_view_safeguarding_information: [],
                    ratifying_provider_can_view_safeguarding_information: [],
                    training_provider_can_view_diversity_information: [],
                    ratifying_provider_can_view_diversity_information: []).to_h
    end

    def new_relationship_permissions
      ProviderRelationshipPermissions.possible_permissions.inject({}) do |hash, permission|
        hash[permission] = permissions_params[permission].present?
        hash
      end
    end

    def set_up_relationship_objects
      @relationship = ProviderRelationshipPermissions.find(params[:id])
      @provider = Provider.find(params[:provider_id])
      @presenter = ProviderRelationshipPermissionAsProviderUserPresenter.new(@relationship, current_provider_user)
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    def provider_id_and_permission_check
      relationship_providers = [@relationship.training_provider, @relationship.ratifying_provider]
      render_404 and return unless relationship_providers.include?(@provider) &&
                                   current_provider_user.providers.include?(@provider)

      auth = ProviderAuthorisation.new(actor: current_provider_user)
      render_403 unless relationship_providers.map { |p| auth.can_manage_organisation?(provider: p) }.any?
    end

    def require_accredited_provider_setting_permissions_flag
      unless FeatureFlag.active?(:accredited_provider_setting_permissions)
        redirect_to(provider_interface_account_path)
      end
    end
  end
end
