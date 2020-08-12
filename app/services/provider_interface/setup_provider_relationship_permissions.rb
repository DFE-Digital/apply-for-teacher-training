module ProviderInterface
  class PermissionsSetupError < StandardError; end

  class SetupProviderRelationshipPermissions
    def self.call(permissions_data = {})
      ProviderRelationshipPermissions.transaction do
        permissions_data.each do |id, permissions|
          record = ProviderRelationshipPermissions.find(id)
          raise PermissionsSetupError, 'Permissions record has already been setup' if record.setup_at.present?

          record.update!(permissions_attributes_for_persistence(permissions))
        end
      end

      true
    end

    def self.permissions_attributes_for_persistence(permissions)
      %w[training ratifying].reduce({ setup_at: Time.zone.now }) do |hash, role|
        hash.merge({
          "#{role}_provider_can_make_decisions" => permissions.fetch('make_decisions', []).include?(role),
          "#{role}_provider_can_view_safeguarding_information" => permissions.fetch('view_safeguarding_information', []).include?(role),
        })
      end
    end
  end
end
