module ProviderInterface
  class UserCardComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def user_with_permissions
      provider_user = example_provider_user
      render UserCardComponent.new(
        provider_user: provider_user,
        provider: provider_user.providers.first,
      )
    end

    def user_without_permissions
      provider_user = FactoryBot.create(:provider_user, :with_provider)
      render UserCardComponent.new(
        provider_user: provider_user,
        provider: provider_user.providers.first,
      )
    end

  private

    def example_provider_user
      permissions = FactoryBot.create(
        :provider_permissions,
        manage_users: Faker::Boolean.boolean(true_ratio: 0.5),
        manage_organisations: Faker::Boolean.boolean(true_ratio: 0.5),
        set_up_interviews: Faker::Boolean.boolean(true_ratio: 0.5),
        make_decisions: Faker::Boolean.boolean(true_ratio: 0.5),
        view_safeguarding_information: Faker::Boolean.boolean(true_ratio: 0.5),
        view_diversity_information: Faker::Boolean.boolean(true_ratio: 0.5),
      )

      permissions.provider_user
    end
  end
end
