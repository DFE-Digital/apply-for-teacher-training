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

    def checkbox_details_for_providers(permission_name)
      ordered_provider_types.map do |provider_type|
        field_name = "#{provider_type}_provider_can_#{permission_name}"

        {
          field_name: field_name,
          label: name_for_provider_of_type(provider_type),
          name: "provider_relationship_permissions[#{field_name}][]",
          checked: provider_relationship_permission.send(field_name),
        }
      end
    end

    def providers_with_permission(permission_name)
      provider_types_with_permission = ordered_provider_types.select do |provider_type|
        provider_relationship_permission.send("#{provider_type}_provider_can_#{permission_name}")
      end

      provider_types_with_permission.map { |provider_type| name_for_provider_of_type(provider_type) }
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
