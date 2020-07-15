module ProviderInterface
  class ProviderPermissionsForm
    include ActiveModel::Model

    Permission = Struct.new(:slug, :name)

    attr_accessor :provider_id, :permissions

    def available_permissions
      [
        Permission.new('manage_users', 'Manage users'),
        Permission.new('make_decisions', 'Make decisions'),
      ]
    end

    def provider
      Provider.find(provider_id)
    end

    alias_method :id, :provider_id
  end
end
