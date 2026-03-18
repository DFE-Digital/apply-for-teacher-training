module ProviderInterface
  class ProviderUserPermissionsFormComponent < ApplicationComponent
    attr_reader :form_model, :provider, :form_path, :form_method, :user_name

    def initialize(form_model:, provider:, form_path:, form_method:, user_name: nil)
      @form_model = form_model
      @provider = provider
      @form_path = form_path
      @form_method = form_method
      @user_name = user_name
    end

  private

    def provider_has_no_relationships?
      ProviderRelationshipPermissions.all_relationships_for_providers([provider]).providers_with_current_cycle_course.none?
    end

    def form_legend
      if provider_has_no_relationships?
        { text: t('page_titles.provider.user_permissions'), size: 'l', tag: 'h1' }
      else
        { text: 'Choose user permissions', size: 'm' }
      end
    end

    def caption_text
      prefix = user_name || 'Add user'
      "#{prefix} - #{provider.name}"
    end

    def form_caption
      { text: caption_text, size: 'l' } if provider_has_no_relationships?
    end
  end
end
