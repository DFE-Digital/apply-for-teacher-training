module ProviderInterface
  class ProviderUserDetailsComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :header

    def initialize(current_provider_user:, provider_user:, provider_permissions:, possible_permissions:)
      @current_provider_user = current_provider_user
      @provider_user = provider_user
      @provider_permissions = provider_permissions
      @header = provider_user.full_name
      @possible_permissions = possible_permissions
    end

    def rows
      (details_rows + [provider_row] + permission_rows).compact
    end

  private

    def details_rows
      [
        { key: 'First name', value: @provider_user.first_name },
        { key: 'Last name', value: @provider_user.last_name },
        { key: 'Email address', value: @provider_user.email_address },
      ]
    end

    def visible_provider_permissions
      @possible_permissions & @provider_permissions
    end

    def provider_row
      manageable_providers = @current_provider_user.authorisation.providers_that_actor_can_manage_users_for
      return if manageable_providers.size == 1

      providers_to_show = @provider_user.providers & manageable_providers
      {
        key: 'Organisations this user has access to',
        value: render(UserDetailsOrganisationsList.new(providers_to_show)),
        change_path: provider_interface_provider_user_edit_providers_path(@provider_user),
        action: 'organisations',
      }
    end

    def permission_rows
      visible_provider_permissions.map do |permission|
        {
          key: "Permissions: #{permission.provider.name}",
          value: render(PermissionsList.new(permission)),
          change_path: provider_interface_provider_user_edit_permissions_path(@provider_user, provider_id: permission.provider.id),
          action: "permissions for #{permission.provider.name}",
        }
      end
    end
  end
end
