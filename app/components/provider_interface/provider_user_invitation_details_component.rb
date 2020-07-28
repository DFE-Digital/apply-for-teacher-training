module ProviderInterface
  class ProviderUserInvitationDetailsComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :header

    def initialize(wizard:)
      @wizard = wizard
    end

    def rows
      [
        first_name_row,
        last_name_row,
        email_address_row,
        providers_row,
      ] + permission_rows
    end

    def first_name_row
      {
        key: 'First name',
        value: @wizard.first_name,
        change_path: provider_interface_update_invitation_basic_details_path(checking_answers: true),
        action: 'first name',
      }
    end

    def last_name_row
      {
        key: 'Last name',
        value: @wizard.last_name,
        change_path: provider_interface_update_invitation_basic_details_path(checking_answers: true),
        action: 'last name',
      }
    end

    def email_address_row
      {
        key: 'Email address',
        value: @wizard.email_address,
        change_path: provider_interface_update_invitation_basic_details_path(checking_answers: true),
        action: 'email address',
      }
    end

    def providers_row
      {
        key: 'Organisations this user will have access to',
        value: provider_names_list,
        change_path: provider_interface_update_invitation_providers_path(checking_answers: true),
        action: 'organisations this user will have access to',
      }
    end

    def permission_rows
      providers.map do |_id, provider|
        {
          key: "Permissions: #{provider.name}",
          value: render(
            ProviderInterface::ProviderUserInvitationPermissionsComponent.new(
              @wizard.provider_permissions[provider.id.to_s]['permissions'].reject(&:blank?),
            ),
          ),
          change_path: provider_interface_update_invitation_provider_permissions_path(
            checking_answers: true,
            provider_id: provider.id,
          ),
          action: "permissions for #{provider.name}",
        }
      end
    end

    def providers
      @providers ||= Provider.find(@wizard.providers).index_by(&:id)
    end

    def provider_names_list
      providers.values.map(&:name)
    end
  end
end
