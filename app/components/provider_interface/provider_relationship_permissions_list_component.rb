module ProviderInterface
  class ProviderRelationshipPermissionsListComponent < ViewComponent::Base
    include ViewHelper
    CHANGE_LINK_ANCHOR_PREFIX = 'provider-interface-provider-relationship-permissions-setup-wizard-provider-relationship-permissions'.freeze

    def initialize(permissions_model:)
      @permissions_model = permissions_model
    end

    def rows
      [
        permissions_row('make decisions'),
        permissions_row('view safeguarding information'),
        permissions_row('view diversity information'),
      ]
    end

  private

    attr_reader :permissions_model
    delegate :ratifying_provider, :training_provider, to: :permissions_model

    def permissions_row(permission_name)
      {
        key: "Which organisations can #{permission_name}?",
        permission_slug: permission_name.parameterize.dasherize,
        change_path: change_path(permission_name.parameterize),
        permissions_list: permissions_list(permission_name.parameterize.underscore),
        action: " which organisations can #{permission_name} for courses run by #{training_provider.name} and ratified by #{ratifying_provider.name}",
      }
    end

    def change_path(permissions_name)
      provider_interface_setup_provider_relationship_permissions_path(
        permissions_model,
        anchor: [CHANGE_LINK_ANCHOR_PREFIX, permissions_model.id, permissions_name, 'training', 'field'].join('-'),
        checking_answers: true,
      )
    end

    def permissions_list(permission_name)
      [
        (permissions_model.send("training_provider_can_#{permission_name}") && training_provider.name) || nil,
        (permissions_model.send("ratifying_provider_can_#{permission_name}") && ratifying_provider.name) || nil,
      ].compact
    end
  end
end
