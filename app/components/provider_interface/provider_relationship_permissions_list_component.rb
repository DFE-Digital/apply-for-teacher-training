module ProviderInterface
  class ProviderRelationshipPermissionsListComponent < ViewComponent::Base
    include ViewHelper

    def initialize(permissions_model:, change_link_builder:)
      @permissions_model = permissions_model
      @change_link_builder = change_link_builder
    end

    def rows
      [
        permissions_row('make decisions'),
        permissions_row('view safeguarding information'),
        permissions_row('view diversity information'),
      ]
    end

  private

    attr_reader :permissions_model, :change_link_builder
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
      change_link_builder.change_link_for(permissions_model, permissions_name)
    end

    def permissions_list(permission_name)
      [
        (permissions_model.send("training_provider_can_#{permission_name}") && training_provider.name) || nil,
        (permissions_model.send("ratifying_provider_can_#{permission_name}") && ratifying_provider.name) || nil,
      ].compact
    end
  end
end
