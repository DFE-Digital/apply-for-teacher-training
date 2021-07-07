module ProviderInterface
  class DsaSuccessPageComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def permission_setup_required
      render DsaSuccessPageComponent.new(
        provider_user: example_provider_user,
        provider_permission_setup_pending: true,
      )
    end

    def permission_setup_not_required
      render DsaSuccessPageComponent.new(
        provider_user: example_provider_user,
        provider_permission_setup_pending: false,
      )
    end

  private

    def example_provider_user
      traits = %i[with_provider]
      traits << :with_manage_users if rand < 0.5
      FactoryBot.create(:provider_user, *traits)
    end
  end
end
