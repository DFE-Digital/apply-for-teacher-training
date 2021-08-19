module ProviderInterface
  class ProviderUserPermissionsFormComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def provider_with_partner_organisation
      provider = FactoryBot.create(:provider)
      setup_relationship_for(provider)
      render ProviderUserPermissionsFormComponent.new(
        form_model: form_model_for(provider),
        form_path: '',
        provider: provider,
        user_name: user_name,
      )
    end

    def self_ratifying_provider
      provider = FactoryBot.create(:provider)
      render ProviderUserPermissionsFormComponent.new(
        form_model: form_model_for(provider),
        form_path: '',
        provider: provider,
        user_name: user_name,
      )
    end

  private

    def setup_relationship_for(provider)
      relationship = FactoryBot.create(:provider_relationship_permissions, training_provider: provider)
      FactoryBot.create(:course, :open_on_apply, provider: provider, accredited_provider: relationship.ratifying_provider)
    end

    def form_model_for(provider)
      provider_permissions = provider_permissions_for(provider)
      enabled_permissions = ProviderPermissions::VALID_PERMISSIONS.map(&:to_s).select { |p| provider_permissions.send(p) }
      PermissionsFormModel.new(permissions: enabled_permissions)
    end

    def provider_permissions_for(provider)
      FactoryBot.create(
        :provider_permissions,
        manage_users: rand > 0.5,
        manage_organisations: rand > 0.5,
        make_decisions: rand > 0.5,
        view_safeguarding_information: rand > 0.5,
        view_diversity_information: rand > 0.5,
        set_up_interviews: rand > 0.5,
        provider: provider,
      )
    end

    def user_name
      rand > 0.5 ? Faker::Name.name : nil
    end

    class PermissionsFormModel
      include ActiveModel::Model

      attr_accessor :permissions
    end
  end
end
