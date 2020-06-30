module ProviderInterface
  class ProviderRelationshipPermissionsController < ProviderInterfaceController
    before_action :render_404_unless_permissions_found
    before_action :render_403_unless_access_permitted

    def setup
      @relationships_pending_setup = TrainingProviderPermissions.where(
        setup_at: nil,
        training_provider: current_provider_user.providers,
      ).includes(%i[training_provider ratifying_provider]).order(:created_at)
    end

    def success; end

    def edit
      initialize_form
    end

    def confirm
      initialize_form
      @form.assign_permissions_attributes(provider_relationship_permissions_form_params)
    end

    def update
      initialize_form

      if @form.update!(provider_relationship_permissions_form_params)
        redirect_to provider_interface_provider_relationship_permissions_success_path
      else
        flash[:warning] = 'Unable to save permissions, please try again. If problems persist please contact support.'
        render :edit
      end
    end

  private

    def initialize_form
      @form = ProviderRelationshipPermissionsForm.new(
        accredited_body_permissions: accredited_body_permissions,
        training_provider_permissions: training_provider_permissions,
      )
    end

    def accredited_body_permissions
      @accredited_body_permissions ||= AccreditedBodyPermissions.find_by(provider_relationship_params)
    end

    def training_provider_permissions
      @training_provider_permissions = \
        if provider_relationship_params[:training_provider_id]
          TrainingProviderPermissions.find_by(provider_relationship_params)
        else
          ProviderSetup.new(provider_user: current_provider_user).next_relationship_pending
        end
    end

    def provider_relationship_params
      params.permit(:ratifying_provider_id, :training_provider_id)
    end

    def provider_relationship_permissions_form_params
      permissions_attrs = ProviderRelationshipPermissions::VALID_PERMISSIONS
      permissions_params = params[:provider_interface_provider_relationship_permissions_form]

      if permissions_params.present?
        permissions_params.permit(
          accredited_body_permissions: permissions_attrs,
          training_provider_permissions: permissions_attrs,
        ).to_h
      else
        {}
      end
    end

    def render_404_unless_permissions_found
      render_404 if accredited_body_permissions.blank? || training_provider_permissions.blank?
    end

    def render_403_unless_access_permitted
      training_provider = training_provider_permissions.training_provider

      render_403 unless ProviderAuthorisation.new(actor: current_provider_user)
        .can_manage_organisation?(provider: training_provider)
    end
  end
end
