module DataMigrations
  class BackfillEnicReason
    TIMESTAMP = 20240729111251
    MANUAL_RUN = false

    def change
      ApplicationQualification.where(enic_reason: nil).where.not(enic_reference: nil).in_batches do |batch|
        batch.update_all(enic_reason: 'obtained')
      end

      ApplicationQualification.where(enic_reason: nil, enic_reference: nil, qualification_type: 'non_uk').in_batches do |batch|
        batch.update_all(enic_reason: 'maybe')
      end

      ApplicationQualification.where(enic_reason: nil, enic_reference: nil).in_batches do |batch|
        batch.update_all(enic_reason: 'not_needed')
      end
    end
  end
end
