module ProviderInterface
  class ProviderRelationshipPermissionsListComponent < ViewComponent::Base
    include ViewHelper
    CHANGE_LINK_ANCHOR_PREFIX = 'provider-interface-provider-relationship-permissions-setup-wizard-provider-relationship-permissions'.freeze

    def initialize(permissions_model:, wizard:)
      @permissions_model = permissions_model
      @wizard = wizard
    end

    def rows
      [
        permissions_row('make decisions'),
        permissions_row('view safeguarding information'),
      ]
    end

  private

    attr_reader :permissions_model, :wizard
    delegate :ratifying_provider, :training_provider, to: :permissions_model

    def permissions_row(permission_name)
      {
        key: "Which organisations can #{permission_name}?",
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
      provider_types_with_enabled_permissions = wizard.permissions_for_relationship(permissions_model.id).fetch(permission_name, [])
      [].tap do |ary|
        ary << training_provider.name if provider_types_with_enabled_permissions.include?('training')
        ary << ratifying_provider.name if provider_types_with_enabled_permissions.include?('ratifying')
      end
    end
  end
end
