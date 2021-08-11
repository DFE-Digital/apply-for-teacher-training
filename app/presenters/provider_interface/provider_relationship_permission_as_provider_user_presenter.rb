module ProviderInterface
  class ProviderRelationshipPermissionAsProviderUserPresenter
    def initialize(relationship:, provider_user:, main_provider: nil)
      @relationship = relationship
      @provider_user = provider_user
      @main_provider = main_provider
    end

    def ordered_providers
      ordered_provider_types.map { |provider_type| send("#{provider_type}_provider") }
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

    def providers_with_permission(permission_name)
      provider_types_with_permission = ordered_provider_types.select do |provider_type|
        relationship.send("#{provider_type}_provider_can_#{permission_name}")
      end

      provider_types_with_permission.map { |provider_type| name_for_provider_of_type(provider_type) }
    end

  private

    attr_reader :relationship, :provider_user, :main_provider

    def ordered_provider_types
      provider_types = %w[training ratifying]

      if main_provider_is_training_provider?
        provider_types
      else
        provider_types.reverse
      end
    end

    def main_provider_is_training_provider?
      main_provider == training_provider ||
        (provider_user_belongs_to_training_provider? && main_provider != ratifying_provider)
    end

    def provider_user_belongs_to_training_provider?
      provider_user.providers.include? training_provider
    end

    def name_for_provider_of_type(provider_type)
      send("#{provider_type}_provider").name
    end

    delegate :training_provider, :ratifying_provider, to: :relationship
  end
end
