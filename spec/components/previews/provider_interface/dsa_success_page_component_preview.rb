module ProviderInterface
  class DsaSuccessPageComponentPreview < ViewComponent::Preview
    include PreviewProviderHelper

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
      if rand < 0.5
        FactoryBot.create(:provider_user, :with_manage_users, providers: [FactoryBot.build(:provider, code: unique_provider_code)])
      else
        FactoryBot.create(:provider_user, providers: [FactoryBot.build(:provider, code: unique_provider_code)])
      end
    end
  end
end
