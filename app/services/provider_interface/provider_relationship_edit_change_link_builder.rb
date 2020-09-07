module ProviderInterface
  class ProviderRelationshipEditChangeLinkBuilder
    CHANGE_LINK_ANCHOR_PREFIX = 'provider-interface-provider-relationship-permissions-form'.freeze

    def self.change_link_for(permissions_model, permissions_name)
      ::Rails.application.routes.url_helpers.provider_interface_edit_provider_relationship_permissions_path(
        permissions_model,
        anchor: [CHANGE_LINK_ANCHOR_PREFIX, permissions_name, 'training', 'field'].join('-'),
      )
    end
  end
end
