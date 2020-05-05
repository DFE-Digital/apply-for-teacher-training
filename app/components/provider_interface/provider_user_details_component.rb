module ProviderInterface
  class ProviderUserDetailsComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :header

    def initialize(provider_user:, provider_permissions:, possible_permissions:)
      @provider_user = provider_user
      @provider_permissions = provider_permissions
      @header = provider_user.full_name
      @possible_permissions = possible_permissions
    end

    def rows
      [
        { key: 'Name', value: @provider_user.full_name },
        { key: 'Email', value: @provider_user.email_address },
        permissions_row,
      ]
    end

    def permissions_row
      {
        key: 'Permissions',
        value: render(
          ProviderInterface::ProviderPermissionsListComponent.new(
            provider_permissions: @provider_permissions,
            possible_permissions: @possible_permissions,
          ),
        ),
        change_path: provider_interface_provider_user_edit_providers_path(@provider_user),
        action: 'Change',
      }
    end
  end
end
