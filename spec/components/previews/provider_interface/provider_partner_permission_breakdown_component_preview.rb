module ProviderInterface
  class ProviderPartnerPermissionBreakdownComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def both_partners_for_which_permission_applies_and_partners_for_which_permission_does_not_apply
      provider = FactoryBot.create(:provider)
      allowed_training_providers = FactoryBot.build_list(:provider, 3)
      allowed_ratifying_providers = FactoryBot.build_list(:provider, 2)
      prohibited_training_providers = FactoryBot.build_list(:provider, 1)
      prohibited_ratifying_providers = FactoryBot.build_list(:provider, 1)

      allowed_training_providers.each do |training_provider|
        FactoryBot.create(:provider_relationship_permissions,
                          training_provider: training_provider,
                          training_provider_can_make_decisions: false,
                          ratifying_provider: provider,
                          ratifying_provider_can_make_decisions: true)
      end

      allowed_ratifying_providers.each do |training_provider|
        FactoryBot.create(:provider_relationship_permissions,
                          ratifying_provider: training_provider,
                          ratifying_provider_can_make_decisions: false,
                          training_provider: provider,
                          training_provider_can_make_decisions: true)
      end

      prohibited_training_providers.each do |training_provider|
        FactoryBot.create(:provider_relationship_permissions,
                          ratifying_provider: provider,
                          training_provider: training_provider,
                          training_provider_can_make_decisions: true,
                          ratifying_provider_can_make_decisions: false)
      end

      prohibited_ratifying_providers.each do |training_provider|
        FactoryBot.create(:provider_relationship_permissions,
                          ratifying_provider: training_provider,
                          training_provider: provider,
                          training_provider_can_make_decisions: false,
                          ratifying_provider_can_make_decisions: true)
      end

      render ProviderPartnerPermissionBreakdownComponent.new(
        provider: provider,
        permission: :make_decisions,
      )
    end

    def only_partners_for_which_permission_applies
      provider = FactoryBot.create(:provider)
      allowed_training_providers = FactoryBot.build_list(:provider, 3)
      allowed_ratifying_providers = FactoryBot.build_list(:provider, 2)

      allowed_training_providers.each do |training_provider|
        FactoryBot.create(:provider_relationship_permissions,
                          training_provider: training_provider,
                          training_provider_can_make_decisions: false,
                          ratifying_provider: provider,
                          ratifying_provider_can_make_decisions: true)
      end

      allowed_ratifying_providers.each do |training_provider|
        FactoryBot.create(:provider_relationship_permissions,
                          ratifying_provider: training_provider,
                          ratifying_provider_can_make_decisions: false,
                          training_provider: provider,
                          training_provider_can_make_decisions: true)
      end

      render ProviderPartnerPermissionBreakdownComponent.new(
        provider: provider,
        permission: :make_decisions,
      )
    end

    def only_partners_for_which_permission_does_not_apply
      provider = FactoryBot.create(:provider)
      prohibited_training_providers = FactoryBot.build_list(:provider, 1)
      prohibited_ratifying_providers = FactoryBot.build_list(:provider, 1)

      prohibited_training_providers.each do |training_provider|
        FactoryBot.create(:provider_relationship_permissions,
                          ratifying_provider: provider,
                          training_provider: training_provider,
                          training_provider_can_make_decisions: true,
                          ratifying_provider_can_make_decisions: false)
      end

      prohibited_ratifying_providers.each do |training_provider|
        FactoryBot.create(:provider_relationship_permissions,
                          ratifying_provider: training_provider,
                          training_provider: provider,
                          training_provider_can_make_decisions: false,
                          ratifying_provider_can_make_decisions: true)
      end

      render ProviderPartnerPermissionBreakdownComponent.new(
        provider: provider,
        permission: :make_decisions,
      )
    end
  end
end
