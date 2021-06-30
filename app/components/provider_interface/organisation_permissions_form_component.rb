module ProviderInterface
  class OrganisationPermissionsFormComponent < ViewComponent::Base
    attr_reader :provider_user, :provider_relationship_permission, :mode, :form_url

    def initialize(provider_user:, provider_relationship_permission:, mode:, form_url:)
      @provider_user = provider_user
      @provider_relationship_permission = provider_relationship_permission
      @mode = mode
      @form_url = form_url
    end

    def page_caption
      if mode == :edit
        provider_relationship_description
      elsif mode == :setup
        t('.setup.caption')
      end
    end

    def page_heading
      if mode == :edit
        t('.edit.heading')
      elsif mode == :setup
        provider_relationship_description
      end
    end

    def checkbox_details_for_providers
      ordered_providers.map do |provider_type|
        {
          name: name_for_provider_of_type(provider_type),
          type: provider_type,
        }
      end
    end

    def label_for(permission_name)
      "Who can #{t("provider_relationship_permissions.#{permission_name}.description").downcase}?"
    end

    def form_method
      if mode == :edit
        :patch
      elsif mode == :setup
        :post
      end
    end

  private

    def provider_relationship_description
      provider_names = ordered_providers.map { |provider_type| name_for_provider_of_type(provider_type) }
      provider_names.join(' and ')
    end

    def ordered_providers
      providers = %w[training ratifying]

      if provider_user_belongs_to_training_provider?
        providers
      else
        providers.reverse
      end
    end

    def provider_user_belongs_to_training_provider?
      provider_user.providers.include? training_provider
    end

    def name_for_provider_of_type(provider_type)
      send("#{provider_type}_provider").name
    end

    def training_provider
      @training_provider ||= provider_relationship_permission.training_provider
    end

    def ratifying_provider
      @ratifying_provider ||= provider_relationship_permission.ratifying_provider
    end
  end
end
