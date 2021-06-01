module ProviderInterface
  class ProviderRelationshipPermissionsSetupController < ProviderInterfaceController
    before_action :require_manage_organisations_permission!
    before_action :require_access_to_manage_provider_relationship_permissions!, only: %i[setup_permissions save_permissions]
    before_action :redirect_unless_permissions_to_setup, except: %i[success]

    def organisations
      @grouped_provider_names_from_relationships = grouped_provider_names_from_relationships
      @permissions_model = provider_relationship_permissions_needing_setup.first
      @wizard = wizard_for(provider_relationships_attrs.merge(current_step: 'provider_relationships'))
      @wizard.save_state!
    end

    def setup_permissions
      @permissions_model = ProviderRelationshipPermissions.find(params[:id])
      @wizard = wizard_for(
        current_step: 'permissions',
        current_provider_relationship_id: params[:id],
        checking_answers: params[:checking_answers],
      )
      @wizard.save_state!

      @permissions_form = @wizard.current_permissions_form
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
        @permissions_form = @wizard.current_permissions_form
        track_validation_error(@wizard)

        render :setup_permissions
      end
    end

    def check
      @wizard = wizard_for(current_step: 'check')
      @wizard.save_state!
      @permissions_models = @wizard.permissions_for_persistence
    end

    def commit
      @wizard = wizard_for({})
      if SetupProviderRelationshipPermissions.call(@wizard.permissions_for_persistence)
        @wizard.clear_state!
        redirect_to provider_interface_provider_relationship_permissions_success_path
      else
        redirect_to(
          provider_interface_check_provider_relationship_permissions_path,
          warning: 'Unable to save permissions, please try again. If problems persist please contact support',
        )
      end
    end

    def success; end

    def previous_page
      step, id = @wizard.previous_step

      path_info = {
        organisations: { action: :organisations },
        permissions: { action: :setup_permissions, id: id },
        check: { action: :check },
      }.fetch(step)

      path_info[:checking_answers] = true if params[:checking_answers]
      path_info
    end
    helper_method :previous_page

  private

    def grouped_provider_names_from_relationships
      provider_relationship_permissions_needing_setup
        .each_with_object({}) do |prp, h|
        h[prp.training_provider.name] ||= []
        h[prp.training_provider.name] << prp.ratifying_provider.name
      end
    end

    def provider_relationship_permissions_needing_setup
      ProviderSetup.new(provider_user: current_provider_user).relationships_pending
    end

    def provider_relationships_attrs
      { provider_relationships: provider_relationship_permissions_needing_setup.pluck(:id) }
    end

    def wizard_for(options)
      options[:checking_answers] = true if params[:checking_answers] == 'true'
      ProviderRelationshipPermissionsSetupWizard.new(
        WizardStateStores::RedisStore.new(key: persistence_key_for_current_user),
        options,
      )
    end

    def require_manage_organisations_permission!
      render_404 unless current_provider_user.authorisation.can_manage_organisations_for_at_least_one_provider?
    end

    def require_access_to_manage_provider_relationship_permissions!
      provider_relationship_permissions = ProviderRelationshipPermissions.find(params[:id])
      permitted_relationship_permissions = current_provider_user.authorisation.training_provider_relationships_that_actor_can_manage_organisations_for

      render_403 unless permitted_relationship_permissions.include?(provider_relationship_permissions)
    end

    def redirect_unless_permissions_to_setup
      redirect_to provider_interface_applications_path if provider_relationship_permissions_needing_setup.blank?
    end

    def permissions_params
      return {} unless params.key?(:provider_interface_provider_relationship_permissions_setup_wizard)

      params.require(:provider_interface_provider_relationship_permissions_setup_wizard)
        .permit(provider_relationship_permissions: {}).to_h
        .merge(current_provider_relationship_id: params[:id], checking_answers: params[:checking_answers])
    end

    def persistence_key_for_current_user
      "provider_user_permissions_wizard-#{current_provider_user.id}"
    end
  end
end
