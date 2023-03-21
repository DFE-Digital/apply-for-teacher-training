module DataMigrations
  class TruncateLongQualificationTypeValues
    TIMESTAMP = 20230320223629
    MANUAL_RUN = false

    def change
      long_qualification_type_qualifications.find_each do |qualification|
        qualification.qualification_type = qualification.qualification_type.truncate(
          ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH,
        )
        qualification.save!
      end

      long_non_uk_qualification_type_qualifications.find_each do |qualification|
        qualification.non_uk_qualification_type = qualification.non_uk_qualification_type.truncate(
          ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH,
        )
        qualification.save!
      end
    end

  private

    def long_qualification_type_qualifications
      ApplicationQualification.where(
        "length(qualification_type) > #{ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH}",
      )
    end

    def long_non_uk_qualification_type_qualifications
      ApplicationQualification.where(
        "length(non_uk_qualification_type) > #{ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH}",
      )
    end
  end
end
