module ProviderInterface
  class ProviderRelationshipPermissionsListComponent < ViewComponent::Base
    include ViewHelper

    def initialize(permissions_model:, change_link_builder:, editable: true, heading_level: 3)
      @permissions_model = permissions_model
      @change_link_builder = change_link_builder
      @editable = editable
      @heading_level = heading_level
    end

    def title
      "#{permissions_model.training_provider.name} and #{permissions_model.ratifying_provider.name}"
    end

    def rows
      [
        view_applications_permissions_row,
        permissions_row('make decisions'),
        permissions_row('view safeguarding information'),
        permissions_row('view diversity information'),
      ]
    end

  private

    attr_reader :permissions_model, :change_link_builder, :editable
    delegate :ratifying_provider, :training_provider, to: :permissions_model

    def permissions_row(permission_name)
      {
        key: "Who can #{permission_name}?",
        permission_slug: permission_name.parameterize.dasherize,
        change_path: change_path(permission_name.parameterize),
        permissions_list: permissions_list(permission_name.parameterize.underscore),
        action: "which organisations can #{permission_name} for courses run by #{training_provider.name} and ratified by #{ratifying_provider.name}",
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

    def view_applications_permissions_row
      {
        key: 'Who can view applications?',
        permission_slug: 'view-applications',
        permissions_list: [training_provider.name, ratifying_provider.name],
      }
    end
  end
end
