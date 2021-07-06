module ProviderInterface
  class OrganisationPermissionsReviewCardComponent < ViewComponent::Base
    attr_reader :presenter, :provider_relationship_permission, :change_path

    def initialize(provider_user:, provider_relationship_permission:, change_path: nil)
      @provider_relationship_permission = provider_relationship_permission
      @presenter = ProviderRelationshipPermissionAsProviderUserPresenter.new(provider_relationship_permission, provider_user)
      @change_path = change_path
    end

    def permission_rows
      ProviderRelationshipPermissions::PERMISSIONS.map do |permission_name|
        {
          key: label_for(permission_name),
          value: providers_to_render_for(permission_name),
        }
      end
    end

  private

    def label_for(permission_name)
      t("provider_relationship_permissions.#{permission_name}.description")
    end

    def providers_to_render_for(permission_name)
      list_items = presenter.providers_with_permission(permission_name).map do |provider_name|
        tag.li(provider_name)
      end

      provider_list = tag.ul(class: 'govuk-list') do
        list_items.join.html_safe
      end

      provider_list.html_safe
    end
  end
end
