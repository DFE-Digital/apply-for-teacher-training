module ProviderInterface
  class EditProviderUserPermissionsComponentPreview < ViewComponent::Preview
    def peter_rovider_permissions
      peter_rovider = ProviderUser.find_by_dfe_sign_in_uid('dev-provider')
      model = ProviderPermissions.where(provider_user: peter_rovider).sample

      render_component_for model: model
    end

  private

    def render_component_for(model:)
      if model.present?
        form = ProviderInterface::ProviderUserEditPermissionsForm.from(model)

        render ProviderInterface::EditProviderUserPermissionsComponent.new(form: form)
      else
        render template: 'support_interface/docs/missing_test_data'
      end
    end
  end
end
