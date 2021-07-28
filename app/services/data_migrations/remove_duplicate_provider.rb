module DataMigrations
  class RemoveDuplicateProvider
    TIMESTAMP = 20210828151830
    MANUAL_RUN = false

    def change
      permissions = ProviderRelationshipPermissions
        .joins('INNER JOIN providers tp ON training_provider_id = tp.id')
        .joins('INNER JOIN providers rp ON ratifying_provider_id = rp.id')
        .where('tp.name = rp.name')

      if permissions.any?
        permissions.each do |permission|
          # Do nothing if the ratifying provider runs courses
          next if permission.ratifying_provider.courses.any?
          # Do nothing if the ratifying provider has additional org relationships
          next if ProviderRelationshipPermissions
            .where(ratifying_provider: permission.ratifying_provider)
            .where.not(training_provider: permission.training_provider).any?

          courses = permission.training_provider.courses.where(accredited_provider: permission.ratifying_provider)

          # Do nothing if the ratifying provider ratifies other courses
          next if (permission.ratifying_provider.accredited_courses - courses).any?

          ActiveRecord::Base.transaction do
            courses.each do |course|
              course.update!(accredited_provider: nil)
            end

            permission.destroy!

            # Ensure we don't orphan any users who were only associated with the duplicate provider
            if permission.ratifying_provider.provider_users.select { |user| user.providers.size == 1 }.any?
              Rails.logger.warn "Skipping deletion of #{permission.ratifying_provider.name}. This organisation has users which do not belong to any other provider."
            else
              permission.destroy!
              permission.ratifying_provider.destroy!
            end
          end
        end
      end
    end
  end
end
