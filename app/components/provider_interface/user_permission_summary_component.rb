module ProviderInterface
  class UserPermissionSummaryComponent < ApplicationComponent
    attr_reader :provider_user, :provider, :editable

    def initialize(provider_user:, provider:, editable: false)
      @provider_user = provider_user
      @editable = editable
      @provider = provider
    end

  private

    def display_provider_permissions_text?(permission)
      ProviderRelationshipPermissions::PERMISSIONS.include?(permission) && can_perform_permission?(permission) && !self_ratifying_provider?
    end

    def can_perform_permission?(permission)
      provider_user.provider_permissions.exists?(provider:, permission => true)
    end

    def self_ratifying_provider?
      ProviderRelationshipPermissions.all_relationships_for_providers([@provider]).providers_with_current_cycle_course.none?
    end

    def can_perform_permission_y_n?(permission)
      can_perform_permission?(permission) ? 'Yes' : 'No'
    end

    def description_for(permission)
      I18n.t("user_permissions.#{permission}.description")
    end
  end
end
