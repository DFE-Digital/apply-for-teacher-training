module ProviderInterface
  class ProviderPartnerPermissionBreakdownComponentPreview < ViewComponent::Preview
    include PreviewProviderHelper

    layout 'previews/provider'

    def both_partners_for_which_permission_applies_and_partners_for_which_permission_does_not_apply
      allowed_training_providers = build_provider_list(3)
      allowed_ratifying_providers = build_provider_list(2)
      prohibited_training_providers = build_provider_list(1)
      prohibited_ratifying_providers = build_provider_list(1)

      allowed_training_providers.each do |training_provider|
        FactoryBot.create(:provider_relationship_permissions,
                          training_provider:,
                          training_provider_can_make_decisions: false,
                          ratifying_provider: provider,
                          ratifying_provider_can_make_decisions: true)
        FactoryBot.create(:course, :open, provider: training_provider, accredited_provider: provider)
      end

      allowed_ratifying_providers.each do |training_provider|
        FactoryBot.create(:provider_relationship_permissions,
                          ratifying_provider: training_provider,
                          ratifying_provider_can_make_decisions: false,
                          training_provider: provider,
                          training_provider_can_make_decisions: true)
        FactoryBot.create(:course, :open, provider:, accredited_provider: training_provider)
      end

      prohibited_training_providers.each do |training_provider|
        FactoryBot.create(:provider_relationship_permissions,
                          ratifying_provider: provider,
                          training_provider:,
                          training_provider_can_make_decisions: true,
                          ratifying_provider_can_make_decisions: false)
        FactoryBot.create(:course, :open, provider: training_provider, accredited_provider: provider)
      end

      prohibited_ratifying_providers.each do |training_provider|
        FactoryBot.create(:provider_relationship_permissions,
                          ratifying_provider: training_provider,
                          training_provider: provider,
                          training_provider_can_make_decisions: false,
                          ratifying_provider_can_make_decisions: true)
        FactoryBot.create(:course, :open, provider:, accredited_provider: training_provider)
      end

      render ProviderPartnerPermissionBreakdownComponent.new(
        provider:,
        permission: :make_decisions,
      )
    end

    def only_partners_for_which_permission_applies
      allowed_training_providers = build_provider_list(3)
      allowed_ratifying_providers = build_provider_list(2)

      allowed_training_providers.each do |training_provider|
        FactoryBot.create(:provider_relationship_permissions,
                          training_provider:,
                          training_provider_can_make_decisions: false,
                          ratifying_provider: provider,
                          ratifying_provider_can_make_decisions: true)
        FactoryBot.create(:course, :open, provider: training_provider, accredited_provider: provider)
      end

      allowed_ratifying_providers.each do |training_provider|
        FactoryBot.create(:provider_relationship_permissions,
                          ratifying_provider: training_provider,
                          ratifying_provider_can_make_decisions: false,
                          training_provider: provider,
                          training_provider_can_make_decisions: true)
        FactoryBot.create(:course, :open, provider:, accredited_provider: training_provider)
      end

      render ProviderPartnerPermissionBreakdownComponent.new(
        provider:,
        permission: :make_decisions,
      )
    end

    def only_partners_for_which_permission_does_not_apply
      prohibited_training_providers = build_provider_list(1)
      prohibited_ratifying_providers = build_provider_list(1)

      prohibited_training_providers.each do |training_provider|
        FactoryBot.create(:provider_relationship_permissions,
                          ratifying_provider: provider,
                          training_provider:,
                          training_provider_can_make_decisions: true,
                          ratifying_provider_can_make_decisions: false)
        FactoryBot.create(:course, :open, provider: training_provider, accredited_provider: provider)
      end

      prohibited_ratifying_providers.each do |training_provider|
        FactoryBot.create(:provider_relationship_permissions,
                          ratifying_provider: training_provider,
                          training_provider: provider,
                          training_provider_can_make_decisions: false,
                          ratifying_provider_can_make_decisions: true)
        FactoryBot.create(:course, :open, provider:, accredited_provider: training_provider)
      end

      render ProviderPartnerPermissionBreakdownComponent.new(
        provider:,
        permission: :make_decisions,
      )
    end

  private

    def provider
      @provider ||= FactoryBot.create(:provider, code: unique_provider_code)
    end

    def build_provider_list(number_of_providers = 1)
      providers_list = []

      number_of_providers.times do
        providers_list << FactoryBot.build(:provider, code: unique_provider_code)
      end
      providers_list
    end
  end
end
