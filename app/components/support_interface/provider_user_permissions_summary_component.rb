module SupportInterface
  class ProviderUserPermissionsSummaryComponent < SummaryListComponent
    include ViewHelper

    attr_reader :provider_user

    def initialize(provider_user)
      @provider_user = provider_user
    end

    def rows
      provider_user
        .provider_permissions
        .includes(provider: %i[ratifying_provider_permissions training_provider_permissions])
        .map do |permission|
        {
          key: permission.provider.name_and_code,
          value: render(SupportInterface::PermissionsListComponent.new(permission)),
          action: 'permissions',
          change_path: change_path,
          data_qa: "provider-id-#{permission.provider.id}",
        }
      end
    end

  private

    def change_path
      if FeatureFlag.active?(:new_provider_user_flow)
        support_interface_edit_permissions_path(provider_user)
      else
        edit_support_interface_provider_user_path(provider_user)
      end
    end
  end
end
