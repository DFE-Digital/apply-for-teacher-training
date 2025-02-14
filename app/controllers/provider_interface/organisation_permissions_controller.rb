module ProviderInterface
  class OrganisationPermissionsController < ProviderInterfaceController
    include ProviderRelationshipPermissionsParamsHelper

    before_action :set_up_relationship_objects, except: :index
    before_action :organisation_id_and_permission_check, except: :index

    def index
      unsorted_provider_relationships = provider_relationships_to_display
      @provider_relationships = sort_relationships_by_provider_name(unsorted_provider_relationships, provider)
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    def edit; end

    def update
      if @relationship.update(new_relationship_permissions)
        SendOrganisationPermissionsEmails.new(provider_user: current_provider_user, provider:, permissions: @relationship).call

        flash[:success] = 'Organisation permissions updated'
        redirect_to provider_interface_organisation_settings_organisation_organisation_permissions_path(params[:organisation_id])
      else
        track_validation_error(@relationship)
        render :edit
      end
    end

  private

    def provider
      @provider ||= current_provider_user.providers.find(params[:organisation_id])
    end

    def permissions_params
      return {} unless params.key?(:provider_relationship_permissions)

      params.require(:provider_relationship_permissions)
            .permit(make_decisions: [],
                    view_safeguarding_information: [],
                    view_diversity_information: []).to_h
    end

    def new_relationship_permissions
      translate_params_for_model(permissions_params)
    end

    def set_up_relationship_objects
      @relationship = ProviderRelationshipPermissions.find(params[:id])
      @provider = Provider.find(params[:organisation_id])
      @presenter = ProviderRelationshipPermissionAsProviderUserPresenter.new(
        relationship: @relationship,
        provider_user: current_provider_user,
        main_provider: @provider,
      )
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    def organisation_id_and_permission_check
      relationship_providers = [@relationship.training_provider, @relationship.ratifying_provider]
      render_404 and return unless relationship_providers.include?(@provider) &&
                                   current_provider_user.providers.include?(@provider)

      auth = ProviderAuthorisation.new(actor: current_provider_user)
      render_403 unless relationship_providers.map { |p| auth.can_manage_organisation?(provider: p) }.any?
    end

    def provider_relationships_to_display
      ProviderRelationshipPermissions.includes(:training_provider, :ratifying_provider).all_relationships_for_providers([provider]).providers_with_current_cycle_course
    end

    def sort_relationships_by_provider_name(relationships, provider)
      relationships.sort_by do |relationship|
        relationship.training_provider == provider ? relationship.ratifying_provider.name : relationship.training_provider.name
      end
    end

    def change_link_for_relationship(relationship)
      if current_provider_user.authorisation.can_manage_organisation?(provider:)
        edit_provider_interface_organisation_settings_organisation_organisation_permission_path(relationship, organisation_id: provider.id)
      end
    end

    helper_method :change_link_for_relationship
  end
end
