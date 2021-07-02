module ProviderInterface
  class ProviderRelationshipPermissionAsProviderUserPresenter
    def initialize(provider_relationship_permission, provider_user)
      @provider_relationship_permission = provider_relationship_permission
      @provider_user = provider_user
    end

    def provider_relationship_description
      provider_names = ordered_provider_types.map { |provider_type| name_for_provider_of_type(provider_type) }
      provider_names.join(' and ')
    end

    def checkbox_details_for_providers
      ordered_provider_types.map do |provider_type|
        {
          name: name_for_provider_of_type(provider_type),
          type: provider_type,
        }
      end
    end

  private

    attr_reader :provider_relationship_permission, :provider_user

    def ordered_provider_types
      provider_types = %w[training ratifying]

      if provider_user_belongs_to_training_provider?
        provider_types
      else
        provider_types.reverse
      end
    end

    def provider_user_belongs_to_training_provider?
      provider_user.providers.include? training_provider
    end

    def name_for_provider_of_type(provider_type)
      send("#{provider_type}_provider").name
    end

    delegate :training_provider, :ratifying_provider, to: :provider_relationship_permission
  end
end
