module DataMigrations
  class BackfillEnicReferenceData
    TIMESTAMP = 20210315122316
    MANUAL_RUN = false

    def change
      ApplicationQualification
        .where.not(naric_reference: nil)
        .where(enic_reference: nil)
        .find_each do |qualification|
          qualification.update!(enic_reference: qualification.naric_reference)
        end
    end
  end
end
