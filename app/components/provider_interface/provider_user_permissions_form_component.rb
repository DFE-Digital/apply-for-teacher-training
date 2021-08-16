module ProviderInterface
  class ProviderUserPermissionsFormComponent < ViewComponent::Base
    attr_reader :form_model, :provider, :form_path, :user_name

    def initialize(form_model:, form_path:, provider:, user_name: nil)
      @form_model = form_model
      @provider = provider
      @form_path = form_path
      @user_name = user_name
    end

  private

    def provider_has_no_relationships?
      ProviderRelationshipPermissions.all_relationships_for_providers([provider]).providers_have_open_course.none?
    end

    def form_legend
      if provider_has_no_relationships?
        { text: t('page_titles.provider.edit_user_permissions'), size: 'l', tag: 'h1' }
      else
        { text: 'Choose user permissions', size: 'm' }
      end
    end

    def caption_text
      prefix = user_name || 'Invite user'
      "#{prefix} - #{provider.name}"
    end

    def form_caption
      { text: caption_text, size: 'l' } if provider_has_no_relationships?
    end
  end
end
