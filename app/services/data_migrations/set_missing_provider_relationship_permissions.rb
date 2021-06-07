module DataMigrations
  class SetMissingProviderRelationshipPermissions
    TIMESTAMP = 20210607134802
    MANUAL_RUN = true

    def change
      Course.all.each do |course|
        next if ProviderRelationshipPermissions.exists?(training_provider: course.provider,
                                                        ratifying_provider: course.accredited_provider)

        ProviderRelationshipPermissions.new(training_provider: course.provider,
                                            ratifying_provider: course.accredited_provider).save!
      end
    end
  end
end
