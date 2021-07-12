module ProviderInterface
  class OrganisationPermissionsController < ProviderInterfaceController
    before_action :render_404_unless_permissions_found, except: :index
    before_action :render_403_unless_access_permitted, except: :index
    attr_reader :permissions_model

    def index
      @manageable_providers = manageable_providers
    end

    def show
      @provider = current_provider_user.providers.find(params[:id])
      @provider_relationships = ProviderRelationshipPermissions.all_relationships_for_providers([@provider])
    end

    # per provider
    def edit
      @relationship = ProviderRelationshipPermissions.find(params[:id])
      @provider = Provider.find(params[:provider_id])
      @presenter = ProviderRelationshipPermissionAsProviderUserPresenter.new(@relationship, current_provider_user)
    end

    def update
      if true
        flash[:success] = 'Organisation permissions successfully updated'
        redirect_to provider_interface_organisation_settings_organisation_permission_path(Provider.find(params[:provider_id]))
      else
        track_validation_error(@form)
        render :edit
      end
    end

  private

    def manageable_providers
      @_manageable_providers ||= current_provider_user.authorisation.providers_that_actor_can_manage_organisations_for(with_set_up_permissions: true)
    end

    def permissions_params
      return {} unless params.key?(:provider_interface_provider_relationship_permissions_form)

      params.require(:provider_interface_provider_relationship_permissions_form)
            .permit(make_decisions: [], view_safeguarding_information: [], view_diversity_information: []).to_h
    end

    def render_404_unless_permissions_found
      @permissions_model ||= ProviderRelationshipPermissions.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    def render_403_unless_access_permitted
      render_403 unless ProviderAuthorisation.new(actor: current_provider_user)
        .can_manage_organisation?(provider: permissions_model.training_provider)
    end
  end
end
