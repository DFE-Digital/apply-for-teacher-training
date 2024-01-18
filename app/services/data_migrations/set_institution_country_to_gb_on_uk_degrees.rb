module DataMigrations
  class SetInstitutionCountryToGbOnUkDegrees
    TIMESTAMP = 20240111093629
    MANUAL_RUN = true

    def change
      application_qualifications.find_each do |application_qualification|
        application_qualification.update_columns(institution_country: 'GB')
      end
    end

  private

    def application_qualifications
      ApplicationQualification.where(level: 'degree')
                              .where(international: false)
                              .where(institution_country: nil)
    end
  end
end
