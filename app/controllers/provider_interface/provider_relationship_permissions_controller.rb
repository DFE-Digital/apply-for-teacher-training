module ProviderInterface
  class ProviderRelationshipPermissionsController < ProviderInterfaceController
    before_action :render_404_unless_permissions_found
    before_action :render_403_unless_access_permitted

    def edit
      initialize_form
    end

    def update
      initialize_form

      if @form.update!(provider_relationship_permissions_form_params)
        flash[:success] = 'Permissions successfully changed'
        redirect_to provider_interface_organisation_path(provider_relationship_permissions.training_provider)
      else
        flash[:warning] = 'Unable to save permissions, please try again. If problems persist please contact support.'
        render :edit
      end
    end

  private

    def initialize_form
      @form = ProviderRelationshipPermissionsForm.new(permissions: provider_relationship_permissions)
    end

    def provider_relationship_permissions
      @provider_relationship_permissions ||= ProviderRelationshipPermissions.find_by(provider_relationship_params)
    end

    def provider_relationship_params
      params.permit(:ratifying_provider_id, :training_provider_id).to_h
    end

    def provider_relationship_permissions_form_params
      return {} unless params.key?(:provider_interface_provider_relationship_permissions_form)

      params
        .require(:provider_interface_provider_relationship_permissions_form)
        .require(:permissions)
        .permit(*ProviderRelationshipPermissions.permissions_fields)
        .to_h
    end

    def provider_relationship_permissions_params
      provider_relationship_permissions_form_params.fetch(:permissions, {})
    end

    def render_404_unless_permissions_found
      render_404 if provider_relationship_permissions.blank?
    end

    def render_403_unless_access_permitted
      training_provider = provider_relationship_permissions.training_provider

      render_403 unless ProviderAuthorisation.new(actor: current_provider_user)
        .can_manage_organisation?(provider: training_provider)
    end
  end
end
