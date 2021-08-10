module ProviderInterface
  class OrganisationPermissionsReviewCardComponent < ViewComponent::Base
    attr_reader :presenter, :provider_relationship_permission, :summary_card_heading_level, :change_path

    def initialize(provider_user:, provider_relationship_permission:, main_provider: nil, summary_card_heading_level: 2, change_path: nil)
      @provider_relationship_permission = provider_relationship_permission
      @presenter = ProviderRelationshipPermissionAsProviderUserPresenter.new(
        relationship: provider_relationship_permission,
        provider_user: provider_user,
        main_provider: main_provider,
      )
      @summary_card_heading_level = summary_card_heading_level
      @change_path = change_path
    end

    def permission_rows
      ProviderRelationshipPermissions::PERMISSIONS.map do |permission_name|
        {
          key: label_for(permission_name),
          value: providers_with_permission(permission_name),
          paragraph_format: true,
        }
      end
    end

  private

    def providers_with_permission(permission_name)
      presenter.providers_with_permission(permission_name).presence || t('provider_relationship_permissions.no_provider_permitted')
    end

    def label_for(permission_name)
      t("provider_relationship_permissions.#{permission_name}.description")
    end
  end
end
