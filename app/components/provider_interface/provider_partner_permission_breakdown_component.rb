module ProviderInterface
  class ProviderPartnerPermissionBreakdownComponent < ViewComponent::Base
    attr_reader :provider, :permission

    def initialize(provider:, permission:)
      @provider = provider
      @permission = permission
    end

    def partners_for_which_permission_applies
      @partners_for_which_permission_applies ||= Provider.where(id: training_partners_for_which_permission_applies_ids)
                                                         .or(Provider.where(id: ratifying_partners_for_which_permission_applies_ids))
                                                         .order(:name)
    end

    def partners_for_which_permission_does_not_apply
      @partners_for_which_permission_does_not_apply ||= Provider.where(id: training_partners_for_which_permission_does_not_apply_ids)
                                                                .or(Provider.where(id: ratifying_partners_for_which_permission_does_not_apply_ids))
                                                                .order(:name)
    end

    def partners_for_which_permission_applies_text
      if partners_for_which_permission_does_not_apply.any?
        'It currently applies to courses you work on with:'
      else
        'It currently applies to courses you work on with all of your partner organisations:'
      end
    end

    def partners_for_which_permission_does_not_apply_text
      if partners_for_which_permission_applies.any?
        'It currently does not apply to courses you work on with:'
      else
        'It currently does not apply to courses you work on with any of your partner organisations:'
      end
    end

  private

    def training_partners_for_which_permission_applies_ids
      Provider.joins(:training_provider_permissions)
              .where(provider_relationship_permissions: { ratifying_provider: provider,
                                                          "ratifying_provider_can_#{permission}" => true })
              .pluck(:id)
    end

    def ratifying_partners_for_which_permission_applies_ids
      Provider.joins(:ratifying_provider_permissions)
              .where(provider_relationship_permissions: { training_provider: provider,
                                                          "training_provider_can_#{permission}" => true })
              .pluck(:id)
    end

    def training_partners_for_which_permission_does_not_apply_ids
      Provider.joins(:training_provider_permissions)
              .where(provider_relationship_permissions: { ratifying_provider: provider,
                                                          "ratifying_provider_can_#{permission}" => false })
              .pluck(:id)
    end

    def ratifying_partners_for_which_permission_does_not_apply_ids
      Provider.joins(:ratifying_provider_permissions)
              .where(provider_relationship_permissions: { training_provider: provider,
                                                          "training_provider_can_#{permission}" => false })
              .pluck(:id)
    end
  end
end
