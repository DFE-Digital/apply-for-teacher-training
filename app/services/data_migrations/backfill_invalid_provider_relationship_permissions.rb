module DataMigrations
  class BackfillInvalidProviderRelationshipPermissions
    TIMESTAMP = 20210823222729
    MANUAL_RUN = true

    def change
      ProviderRelationshipPermissions.find_each do |permission|
        next unless permission.invalid?

        permission.update!(
          training_provider_can_view_safeguarding_information: true,
          ratifying_provider_can_view_safeguarding_information: true,
          training_provider_can_view_diversity_information: true,
          ratifying_provider_can_view_diversity_information: true,
          audit_comment: 'Backfilling invalid permissions by setting values to true',
        )
      end
    end
  end
end
