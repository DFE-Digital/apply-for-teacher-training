module ProviderInterface
  class ProviderRelationshipPermissionsSetupController < ProviderInterfaceController
    before_action :require_feature_flag!
    before_action :require_manage_organisations_permission!

    def organisations
      @grouped_provider_names_from_relationships = grouped_provider_names_from_relationships
      @wizard = wizard_for(current_step: 'provider_relationships')
      @wizard.save_state!
    end

    def info
      @wizard = wizard_for(current_step: 'info')
      @wizard.save_state!
    end

    def setup_permissions
      @permissions_model = provider_relationship_permissions_needing_setup.first
      @wizard = wizard_for(current_step: 'permissions')
      @wizard.save_state!
    end

    def save_permissions
      @wizard = wizard_for(current_step: 'permissions')
      @wizard.save_state!
    end

    def check
      @wizard = wizard_for(current_step: 'check')
      @wizard.save_state!
    end

    def commit
      @wizard = wizard_for({})
      @wizard.save_state!
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
        .training_providers_that_actor_can_manage_organisations_for
        .where(setup_at: nil)
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
  end
end
