module ProviderInterface
  class ProviderRelationshipPermissionsForm
    include ActiveModel::Model
    attr_accessor :ratifying_provider_permissions, :training_provider_permissions

    def initialize(*args)
      super(*args)
      @doing_setup = [@ratifying_provider_permissions, @training_provider_permissions].any? do |p|
        p.setup_at.blank?
      end
    end

    def doing_setup?
      @doing_setup
    end

    def assign_permissions_attributes(params)
      @ratifying_provider_permissions.assign_attributes(ratifying_provider_permissions_from_params(params))
      @training_provider_permissions.assign_attributes(training_provider_permissions_from_params(params))
    end

    def update!(params)
      @ratifying_provider_permissions.update!(
        ratifying_provider_permissions_from_params(params).merge(setup_at: Time.current),
      ) && @training_provider_permissions.update!(
        training_provider_permissions_from_params(params).merge(setup_at: Time.current),
      )
    end

  private

    def ratifying_provider_permissions_from_params(params)
      permissions_from_params(params.fetch(:ratifying_provider_permissions, {}))
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
