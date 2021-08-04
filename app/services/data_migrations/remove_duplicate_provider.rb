module DataMigrations
  class RemoveDuplicateProvider
    TIMESTAMP = 20210828151830
    MANUAL_RUN = true

    def change
      permissions = ProviderRelationshipPermissions
        .joins('INNER JOIN providers tp ON training_provider_id = tp.id')
        .joins('INNER JOIN providers rp ON ratifying_provider_id = rp.id')
        .where('tp.name = rp.name')

      if permissions.any?
        permissions.each do |permission|
          # Do nothing if the ratifying provider runs courses
          if permission.ratifying_provider.courses.any?
            Rails.logger.warn(
              "Ratifying provider #{permission.ratifying_provider.name_and_code} runs the following courses: " +
              permission.ratifying_provider.courses.map(&:name_and_code).join(', '),
            )

            next
          end

          other_provider_relationships = ProviderRelationshipPermissions
            .where(ratifying_provider: permission.ratifying_provider)
            .where.not(training_provider: permission.training_provider)

          # Do nothing if the ratifying provider has additional org relationships
          if other_provider_relationships.any?
            Rails.logger.warn(
              "Ratifying provider #{permission.ratifying_provider.name_and_code} has other relationships with the following providers: " +
              other_provider_relationships.map { |r| r.training_provider.name }.join(', '),
            )

            next
          end

          courses = permission.training_provider.courses.where(accredited_provider: permission.ratifying_provider)

          ActiveRecord::Base.transaction do
            courses.each do |course|
              course.update!(accredited_provider: nil)
            end

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
