module ProviderInterface
  class ProviderRelationshipPermissionsSetupController < ProviderInterfaceController
    before_action :require_feature_flag!
    before_action :require_manage_organisations_permission!

    def start
      @wizard = wizard_for(current_step: 'start')
      @wizard.save_state!
    end

    def organisations
      @wizard = wizard_for(current_step: 'provider_relationships')
      @wizard.save_state!
    end

    def info
      @wizard = wizard_for(current_step: 'info')
      @wizard.save_state!
    end

    def setup_permissions
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
