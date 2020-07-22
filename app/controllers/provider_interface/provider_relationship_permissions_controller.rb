module ProviderInterface
  class ProviderRelationshipPermissionsController < ProviderInterfaceController
    before_action :render_404_unless_permissions_found
    before_action :render_403_unless_access_permitted

    def edit
      @form = ProviderRelationshipPermissionsForm.new(permissions_model: permissions_model)
    end

    def update
      @form = ProviderRelationshipPermissionsForm.new(permissions_params.merge(permissions_model: permissions_model))

      if @form.save!
        flash[:success] = 'Permissions successfully changed'
        redirect_to provider_interface_organisation_path(permissions_model.training_provider)
      else
        flash[:warning] = 'Unable to save permissions, please try again. If problems persist please contact support.'
        render :edit
      end
    end

  private

    def permissions_model
      ProviderRelationshipPermissions.find_by(
        ratifying_provider_id: params[:ratifying_provider_id],
        training_provider_id: params[:training_provider_id],
      )
    end

    def permissions_params
      return {} unless params.key?(:provider_interface_provider_relationship_permissions_form)

      params.require(:provider_interface_provider_relationship_permissions_form)
            .permit(make_decisions: [], view_safeguarding_information: []).to_h
    end

    def render_404_unless_permissions_found
      render_404 if permissions_model.blank?
    end

    def render_403_unless_access_permitted
      render_403 unless ProviderAuthorisation.new(actor: current_provider_user)
        .can_manage_organisation?(provider: permissions_model.training_provider)
    end
  end
end
