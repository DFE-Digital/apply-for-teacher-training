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

      if permissions.empty?
        [
          {
            key: 'This user does not have access to any providers',
          },
        ]
      else
        permissions.map do |permission|
          {
            key: permission.provider.name_and_code,
            value: render(SupportInterface::PermissionsListComponent.new(permission)),
            actions: [
              { verb: 'Change', object: "permissions for #{permission.provider.name_and_code}", path: change_path },
              { verb: 'Remove access', object: "to #{permission.provider.name_and_code}", path: support_interface_provider_user_removals_path(
                provider_user_id: permission.provider_user.id,
                provider_permissions_id: permission.id,
              ) },
            ],
            data_qa: "provider-id-#{permission.provider.id}",
          }
        end
      end
    end

  private

    def change_path
      support_interface_edit_permissions_path(provider_user)
    end
  end
end
