module ProviderInterface
  class UserPermissionSummaryComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def user_permission_summary
      provider = FactoryBot.create(:provider)
      provider_user = FactoryBot.create(:provider_user)
      current_provider_user = FactoryBot.create(:provider_user)

      FactoryBot.create(:provider_permissions,
                        provider: provider,
                        provider_user: current_provider_user,
                        manage_users: true)

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

      render UserPermissionSummaryComponent.new(
        provider_user: provider_user,
        provider: provider,
        current_user: current_provider_user,
      )
    end
  end
end
