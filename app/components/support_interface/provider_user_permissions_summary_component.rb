module SupportInterface
  class ProviderUserPermissionsSummaryComponent < SummaryListComponent
    include ViewHelper

    attr_reader :provider_user

    def initialize(provider_user)
      @provider_user = provider_user
    end

    def rows
      permissions = provider_user
        .provider_permissions
        .includes(provider: %i[ratifying_provider_permissions training_provider_permissions])
        .order('providers.name')

      if permissions.empty?
        [
          {
            key: 'This user does not have access to any providers',
          },
        ]
      else
        permissions.map do |permission|
          {
            key: "#{permission.provider.name_and_code}<br role='presentation'><br role='presentation'>(#{govuk_link_to('Provider permissions', support_interface_provider_relationships_path(permission.provider))})".html_safe,
            value: render(SupportInterface::PermissionsListComponent.new(permission)),
            actions: [
              {
                href: change_path,
                text: 'Change',
                visually_hidden_text: "permissions for #{permission.provider.name_and_code}",
              },
              {
                href: remove_access_path(permission),
                text: 'Remove access',
                visually_hidden_text: "to #{permission.provider.name_and_code}",
              },
            ],
            html_attributes: {
              data: { qa: "provider-id-#{permission.provider.id}" },
            },
          }
        end
      end
    end

  private

    def change_path
      support_interface_edit_permissions_path(provider_user)
    end

    def remove_access_path(permission)
      support_interface_provider_user_removals_path(
        provider_user_id: provider_user.id,
        provider_permissions_id: permission.id,
      )
    end
  end
end
