module DataMigrations
  class SetMissingProviderRelationshipPermissions
    TIMESTAMP = 20210607134802
    MANUAL_RUN = true

    def change
      Course.all.each do |course|
        next if ratified_by_provider?(course) || provider_relationship_permissions_exist?(course)

        ProviderRelationshipPermissions.new(training_provider: course.provider,
                                            ratifying_provider: course.accredited_provider).save!
      end
    end

  private

    def ratified_by_provider?(course)
      !course.accredited_provider || course.accredited_provider == course.provider
    end

    def provider_relationship_permissions_exist?(course)
      ProviderRelationshipPermissions.exists?(training_provider: course.provider,
                                              ratifying_provider: course.accredited_provider)
    end
  end
end
