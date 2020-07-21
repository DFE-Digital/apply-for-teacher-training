module ProviderInterface
  class ProviderRelationshipPermissionsForm
    include ActiveModel::Model

    attr_accessor :permissions

    def assign_permissions_attributes(attrs)
      @permissions.assign_attributes(permissions_attributes(attrs))
    end

    def update!(attrs)
      @permissions.update!(permissions_attributes(attrs))
    end

  private

    def permissions_attributes(attrs)
      {}.tap do |hash|
        ProviderRelationshipPermissions.permissions_fields.each do |f|
          hash[f] = attrs.fetch(f, false)
        end
      end
    end
  end
end
