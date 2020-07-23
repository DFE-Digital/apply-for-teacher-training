module ProviderInterface
  class ProviderUserInvitationDetailsComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :header

    def initialize(wizard:)
      @wizard = wizard
      @provider_permissions = @wizard.provider_permissions
      # @possible_permissions = @wizard.possible_permissions
    end

    def rows
      [
        first_name_row,
        last_name_row,
        email_address_row,
        providers_row,
      ] #+ permission_rows
    end

    def visible_provider_permissions
      @possible_permissions & @provider_permissions
    end

    def first_name_row
      {
        key: 'First name',
        value: @wizard.first_name,
        change_path: provider_interface_update_invitation_basic_details_path(checking_answers: true),
        action: 'Change',
      }
    end

    def last_name_row
      {
        key: 'Last name',
        value: @wizard.last_name,
        change_path: provider_interface_update_invitation_basic_details_path(checking_answers: true),
        action: 'Change',
      }
    end

    def email_address_row
      {
        key: 'Email address',
        value: @wizard.email_address,
        change_path: provider_interface_update_invitation_basic_details_path(checking_answers: true),
        action: 'Change',
      }
    end

    def providers_row
      {
        key: 'Organisations this user will have access to',
        value: provider_names_list,
        change_path: provider_interface_update_invitation_providers_path(checking_answers: true),
        action: 'Change',
      }
    end

    def permission_rows
      visible_provider_permissions.map do |permission|
        {
          key: "Permissions: #{permission.provider.name}",
          value: render(PermissionsList.new(permission)),
          change_path: provider_interface_provider_user_edit_providers_path(@provider_user, checking_answers: true),
          action: 'Change',
        }
      end
    end

    def provider_names_list
      Provider.find(@wizard.providers).map(&:name)
    end
  end
end
