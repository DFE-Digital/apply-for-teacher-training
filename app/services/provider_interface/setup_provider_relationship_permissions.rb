module ProviderInterface
  class SetupProviderRelationshipPermissions
    def self.call(models)
      ProviderRelationshipPermissions.transaction do
        models.map do |record|
          record.setup_at = Time.zone.now if record.setup_at.blank?
          record.save!
        end
      end

      true
    end
  end
end
