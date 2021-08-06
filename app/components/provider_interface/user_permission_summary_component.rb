module ProviderInterface
  class UserPermissionSummaryComponent < ViewComponent::Base
    attr_reader :provider_user, :provider, :editable

    def initialize(provider_user:, provider:, editable: false)
      @provider_user = provider_user
      @editable = editable
      @provider = provider
    end

  private

    def can_perform_permission?(permission)
      provider_user.provider_permissions.exists?(permission => true)
    end

    def can_perform_permission_y_n?(permission)
      can_perform_permission?(permission) ? 'Yes' : 'No'
    end

    def description_for(permission)
      I18n.t("user_permissions.#{permission}.description")
    end
  end
end
