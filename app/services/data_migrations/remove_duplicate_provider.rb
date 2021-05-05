module DataMigrations
  class RemoveDuplicateProvider
    TIMESTAMP = 20210505095417
    MANUAL_RUN = false

    def change
      permissions = ProviderRelationshipPermissions
        .joins('INNER JOIN providers tp ON training_provider_id = tp.id')
        .joins('INNER JOIN providers rp ON ratifying_provider_id = rp.id')
        .where('tp.name = rp.name')

      if permissions.any?
        ActiveRecord::Base.transaction do
          permissions.each do |permission|
            courses = permission.training_provider.courses.where(accredited_provider: permission.ratifying_provider)
            next if courses.empty?

            courses.each do |course|
              course.update!(accredited_provider: nil, audit_comment: 'Deduplicating accredited provider, this course is self-ratified')
            end

            permission.destroy!
            permission.ratifying_provider.destroy!
          end
        end
      end
    end
  end
end
