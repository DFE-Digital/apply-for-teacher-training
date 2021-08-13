module ProviderInterface
  class UserPermissionSummaryComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def editable_permission_summary
      provider_user = example_provider_user
      render UserPermissionSummaryComponent.new(
        provider_user: provider_user,
        provider: provider_user.providers.first,
        editable: true,
      )
    end

    def uneditable_permission_summary
      provider_user = example_provider_user
      render UserPermissionSummaryComponent.new(
        provider_user: provider_user,
        provider: provider_user.providers.first,
      )
    end

  private

    def example_provider_user
      provider = FactoryBot.create(:provider)
      provider_user = FactoryBot.create(:provider_user)

      FactoryBot.create(:provider_permissions,
                        provider: provider,
                        provider_user: provider_user,
                        manage_users: Faker::Boolean.boolean(true_ratio: 0.5),
                        manage_organisations: Faker::Boolean.boolean(true_ratio: 0.5),
                        set_up_interviews: Faker::Boolean.boolean(true_ratio: 0.5),
                        make_decisions: Faker::Boolean.boolean(true_ratio: 0.5),
                        view_safeguarding_information: Faker::Boolean.boolean(true_ratio: 0.5),
                        view_diversity_information: Faker::Boolean.boolean(true_ratio: 0.5))
      providers = FactoryBot.build_list(:provider, 3)
      other_providers = FactoryBot.build_list(:provider, 2)
      random_boolean_value = Faker::Boolean.boolean(true_ratio: 0.5)
      other_random_boolean_value = Faker::Boolean.boolean(true_ratio: 0.5)

      providers.each do |training_provider|
        FactoryBot.create(:provider_relationship_permissions,
                          training_provider: training_provider,
                          ratifying_provider: provider,
                          training_provider_can_make_decisions: random_boolean_value,
                          ratifying_provider_can_make_decisions: !random_boolean_value,
                          training_provider_can_view_safeguarding_information: random_boolean_value,
                          ratifying_provider_can_view_safeguarding_information: !random_boolean_value,
                          training_provider_can_view_diversity_information: random_boolean_value,
                          ratifying_provider_can_view_diversity_information: !random_boolean_value)
      end

      other_providers.each do |training_provider|
        FactoryBot.create(:provider_relationship_permissions,
                          training_provider: training_provider,
                          ratifying_provider: provider,
                          training_provider_can_make_decisions: !other_random_boolean_value,
                          ratifying_provider_can_make_decisions: other_random_boolean_value,
                          training_provider_can_view_safeguarding_information: !other_random_boolean_value,
                          ratifying_provider_can_view_safeguarding_information: other_random_boolean_value,
                          training_provider_can_view_diversity_information: !other_random_boolean_value,
                          ratifying_provider_can_view_diversity_information: other_random_boolean_value)
      end

      provider_user
    end
  end
end
