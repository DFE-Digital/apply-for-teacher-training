module ProviderInterface
  class ProviderPermissionsListComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :provider_permissions, :possible_permissions

    def initialize(provider_permissions:, possible_permissions:)
      @provider_permissions = provider_permissions
      @possible_permissions = possible_permissions
    end

    def visible_provider_permissions
      possible_permissions & provider_permissions
    end

    def humanized_permissions(provider_permission)
      [].tap do |ary|
        ProviderPermissions::VALID_PERMISSIONS.each do |permission_name|
          ary << permission_name.to_s.humanize if provider_permission.send(permission_name)
        end
      end
    end
  end
end
