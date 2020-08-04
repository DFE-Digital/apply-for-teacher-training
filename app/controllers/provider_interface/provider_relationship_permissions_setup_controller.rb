module ProviderInterface
  class ProviderRelationshipPermissionsSetupController < ProviderInterfaceController
    before_action :require_feature_flag!
    before_action :require_manage_organisations_permission!
    before_action :require_access_to_manage_provider_relationship_permissions!, only: %i[setup_permissions save_permissions]

    def organisations
      @grouped_provider_names_from_relationships = grouped_provider_names_from_relationships
      @wizard = wizard_for(provider_relationships_attrs.merge(current_step: 'provider_relationships'))
      @wizard.save_state!
    end

    def info
      @permissions_model = provider_relationship_permissions_needing_setup.first
      @wizard = wizard_for(current_step: 'info')
      @wizard.save_state!
    end

    def setup_permissions
      @permissions_model = ProviderRelationshipPermissions.find(params[:id])
      @wizard = wizard_for(current_step: 'permissions')
      @wizard.save_state!
    end

    def save_permissions
      @wizard = wizard_for(permissions_params.merge(current_step: 'permissions'))

      if @wizard.valid?(:permissions)
        @wizard.save_state!

        next_step, id = @wizard.next_step

        if next_step == :permissions
          redirect_to provider_interface_setup_provider_relationship_permissions_path(id)
        else
          redirect_to provider_interface_check_provider_relationship_permissions_path
        end
      else
        @permissions_model = ProviderRelationshipPermissions.find(params[:id])
        render :setup_permissions
      end
    end

    def check
      @wizard = wizard_for(current_step: 'check')
      @permissions_models = ProviderRelationshipPermissions
        .includes(:training_provider, :ratifying_provider)
        .where(id: @wizard.provider_relationships)
      @wizard.save_state!
    end

    def commit
      @wizard = wizard_for({})
      # TODO: Save permissions
      @wizard.clear_state!
    end

  private

    def grouped_provider_names_from_relationships
      provider_relationship_permissions_needing_setup
        .includes(:training_provider, :ratifying_provider).each_with_object({}) do |prp, h|
        h[prp.training_provider.name] ||= []
        h[prp.training_provider.name] << prp.ratifying_provider.name
      end
    end

    def provider_relationship_permissions_needing_setup
      current_provider_user.authorisation
        .training_provider_relationships_that_actor_can_manage_organisations_for
        .where(setup_at: nil)
        .order(created_at: :asc)
    end

    def provider_relationships_attrs
      { provider_relationships: provider_relationship_permissions_needing_setup.pluck(:id) }
    end

    def wizard_for(options)
      options[:checking_answers] = true if params[:checking_answers] == 'true'
      ProviderRelationshipPermissionsSetupWizard.new(session, options)
    end

    def require_feature_flag!
      render_404 unless FeatureFlag.active?(:enforce_provider_to_provider_permissions)
    end

    def require_manage_organisations_permission!
      render_404 unless current_provider_user.authorisation.can_manage_organisations_for_at_least_one_provider?
    end

    def require_access_to_manage_provider_relationship_permissions!
      provider_relationship_permissions = ProviderRelationshipPermissions.find(params[:id])
      permitted_relationship_permissions = current_provider_user.authorisation.training_provider_relationships_that_actor_can_manage_organisations_for

      render_403 unless permitted_relationship_permissions.include?(provider_relationship_permissions)
    end

    def permissions_params
      return {} unless params.key?(:provider_interface_provider_relationship_permissions_setup_wizard)

      params.require(:provider_interface_provider_relationship_permissions_setup_wizard)
        .permit(make_decisions: [], view_safeguarding_information: []).to_h
        .merge(current_provider_relationship_id: params[:id])
    end
  end
end
