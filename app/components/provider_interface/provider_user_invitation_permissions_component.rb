module ProviderInterface
  class ProviderUserInvitationPermissionsComponent < ViewComponent::Base
    include ViewHelper

    HUMAN_READABLE_PERMISSIONS = {
      'view_safeguarding_information' => 'Access safeguarding information',
      'manage_organisations' => 'Manage organisational permissions',
      'manage_users' => 'Manage users',
      'set_up_interviews' => 'Set up interviews',
      'make_decisions' => 'Make decisions',
      'view_diversity_information' => 'Access diversity information',
    }.freeze

    def initialize(permissions)
      @permissions = permissions
    end

    def permissions
      @permissions.map { |p| HUMAN_READABLE_PERMISSIONS.fetch(p.to_s, nil) }.compact
    end
  end
end
