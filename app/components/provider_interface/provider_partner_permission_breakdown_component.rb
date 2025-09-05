module ProviderInterface
  class ProviderPartnerPermissionBreakdownComponent < ApplicationComponent
    attr_reader :provider, :permission

    def initialize(provider:, permission:)
      @provider = provider
      @permission = permission
    end

    def partners_for_which_permission_applies
      @partners_for_which_permission_applies ||= Provider.where(id: training_provider_partner_ids_where(permission_applies: true))
                                                         .or(Provider.where(id: ratifying_provider_partner_ids_where(permission_applies: true)))
                                                         .order(:name)
    end

    def partners_for_which_permission_does_not_apply
      @partners_for_which_permission_does_not_apply ||= Provider.where(id: training_provider_partner_ids_where(permission_applies: false))
                                                                .or(Provider.where(id: ratifying_provider_partner_ids_where(permission_applies: false)))
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

    def training_provider_partner_ids_where(permission_applies:)
      provider.ratifying_provider_permissions
              .providers_with_current_cycle_course
              .where("ratifying_provider_can_#{permission}" => permission_applies)
              .pluck(:training_provider_id)
    end

    def ratifying_provider_partner_ids_where(permission_applies:)
      provider.training_provider_permissions
              .providers_with_current_cycle_course
              .where("training_provider_can_#{permission}" => permission_applies)
              .pluck(:ratifying_provider_id)
    end
  end
end
