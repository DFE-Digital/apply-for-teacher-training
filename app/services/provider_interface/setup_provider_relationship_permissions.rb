module ProviderInterface
  class PermissionsSetupError < StandardError; end

  class SetupProviderRelationshipPermissions
    def self.call(models)
      ProviderRelationshipPermissions.transaction do
        models.map do |record|
          raise PermissionsSetupError, 'Permissions record has already been setup' if record.setup_at.present?

          record.setup_at = Time.zone.now
          record.save!
        end
      end

      true
    end
  end
end
