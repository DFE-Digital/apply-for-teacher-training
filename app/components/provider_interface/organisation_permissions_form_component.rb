module ProviderInterface
  class OrganisationPermissionsFormComponent < ViewComponent::Base
    attr_reader :presenter, :provider_relationship_permission, :mode, :form_url

    def initialize(provider_user:, provider_relationship_permission:, mode:, form_url:)
      @provider_relationship_permission = provider_relationship_permission
      @presenter = ProviderRelationshipPermissionAsProviderUserPresenter.new(provider_relationship_permission, provider_user)
      @mode = mode
      @form_url = form_url
    end

    def page_caption
      if mode == :edit
        presenter.provider_relationship_description
      elsif mode == :setup
        t('.setup.caption')
      end
    end

    def page_heading
      if mode == :edit
        t('.edit.heading')
      elsif mode == :setup
        presenter.provider_relationship_description
      end
    end

    def label_for(permission_name)
      permission_description = t("provider_relationship_permissions.#{permission_name}.description")
      t('provider_relationship_permissions.question', permission_description: permission_description.downcase)
    end

    def form_method
      if mode == :edit
        :patch
      elsif mode == :setup
        :post
      end
    end
  end
end
