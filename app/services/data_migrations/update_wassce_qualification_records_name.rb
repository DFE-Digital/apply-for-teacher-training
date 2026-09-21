module DataMigrations
  class UpdateWassceQualificationRecordsName
    TIMESTAMP = 20260921094603
    MANUAL_RUN = false

    def change
      ApplicationQualification.where(
        non_uk_qualification_type: 'WASSCE (West African Senior School Certificate Examination)',
      ).update_all(
        non_uk_qualification_type: 'WAEC, WASSCE (West African Senior School Certificate Examination)',
      )
    end
  end
end
