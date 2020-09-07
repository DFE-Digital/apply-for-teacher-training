module ProviderInterface
  class ProviderRelationshipWizardChangeLinkBuilder
    include ViewHelper
    CHANGE_LINK_ANCHOR_PREFIX = 'provider-interface-provider-relationship-permissions-setup-wizard-provider-relationship-permissions'.freeze

    def self.change_link_for(permissions_model, permissions_name)
      ::Rails.application.routes.url_helpers.provider_interface_setup_provider_relationship_permissions_path(
        permissions_model,
        anchor: [CHANGE_LINK_ANCHOR_PREFIX, permissions_model.id, permissions_name, 'training', 'field'].join('-'),
        checking_answers: true,
      )
    end
  end
end
