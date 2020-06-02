module ProviderInterface
  class ProviderRelationshipPermissionsForm
    include ActiveModel::Model
    attr_accessor :accredited_body_permissions, :training_provider_permissions

    def assign_permissions_attributes(params)
      @accredited_body_permissions.assign_attributes(accredited_body_permissions_from_params(params))
      @training_provider_permissions.assign_attributes(training_provider_permissions_from_params(params))
    end

    def save!
      @accredited_body_permissions.save! && @training_provider_permissions.save!
    end

  private

    def accredited_body_permissions_from_params(params)
      permissions_from_params(params.fetch(:accredited_body_permissions, {}))
    end

    def training_provider_permissions_from_params(params)
      permissions_from_params(params.fetch(:training_provider_permissions, {}))
    end

    def permissions_from_params(params)
      {}.tap do |permissions|
        ProviderRelationshipPermissions::VALID_PERMISSIONS.each do |permission_name|
          permissions[permission_name] = params.fetch(permission_name, false) == 'true'
        end
      end
    end
  end
end
