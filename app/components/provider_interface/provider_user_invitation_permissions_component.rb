module ProviderInterface
  class ProviderUserInvitationPermissionsComponent < ViewComponent::Base
    include ViewHelper

    HUMAN_READABLE_PERMISSIONS = {
      'view_safeguarding_information' => 'Access safeguarding information',
      'manage_organisations' => 'Manage organisations',
      'manage_users' => 'Manage users',
      'make_decisions' => 'Make decisions',
    }.freeze

    def initialize(permissions)
      @permissions = permissions
    end

    def permissions
      @permissions.map { |p| HUMAN_READABLE_PERMISSIONS.fetch(p.to_s) }
    end
  end
end
