module ProviderInterface
  class ProviderUserInvitationDetailsComponent < SummaryListComponent
    include ViewHelper
    attr_reader :header

    def initialize(wizard:)
      @wizard = wizard
    end

    def rows
      rows = [
        first_name_row,
        last_name_row,
        email_address_row,
      ]
      rows << providers_row unless @wizard.single_provider
      rows + permission_rows
    end

    def first_name_row
      {
        key: 'First name',
        value: @wizard.first_name,
        action: {
          href: provider_interface_update_invitation_basic_details_path(checking_answers: true),
        },
      }
    end

    def last_name_row
      {
        key: 'Last name',
        value: @wizard.last_name,
        action: {
          href: provider_interface_update_invitation_basic_details_path(checking_answers: true),
        },
      }
    end

    def email_address_row
      {
        key: 'Email address',
        value: @wizard.email_address,
        action: {
          href: provider_interface_update_invitation_basic_details_path(checking_answers: true),
        },
      }
    end

    def providers_row
      {
        key: 'Organisations this user will have access to',
        value: render(UserDetailsOrganisationsList.new(providers.values)),
        action: {
          href: provider_interface_update_invitation_providers_path(checking_answers: true),
        },
      }
    end

    def permission_rows
      providers.map do |_id, provider|
        key = 'Permissions'
        key += ": #{provider.name}" unless @wizard.single_provider
        {
          key: key,
          value: render(
            ProviderInterface::ProviderUserInvitationPermissionsComponent.new(
              @wizard.provider_permissions[provider.id.to_s].fetch('permissions', []).reject(&:blank?),
            ),
          ),
          action: {
            href: provider_interface_update_invitation_provider_permissions_path(
              checking_answers: true,
              provider_id: provider.id,
            ),
            visually_hidden_text: "permissions for #{provider.name}",
          },
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
