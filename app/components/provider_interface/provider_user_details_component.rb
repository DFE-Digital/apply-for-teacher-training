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
      ] + permission_rows
    end

    def visible_provider_permissions
      @possible_permissions & @provider_permissions
    end

    def permission_rows
      visible_provider_permissions.map do |permission|
        {
          key: "Permissions: #{permission.provider.name}",
          value: render(PermissionsList.new(permission)),
          change_path: provider_interface_provider_user_edit_permissions_path(@provider_user, provider_id: permission.provider.id),
          action: "Change permissions for #{permission.provider.name}",
        }
      end
    end
  end
end
