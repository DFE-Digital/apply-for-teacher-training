module DataMigrations
  class TrimQualificationDegreeTypes
    TIMESTAMP = 20210426215031
    MANUAL_RUN = false

    def change
      ApplicationQualification.where(level: 'degree').find_each do |application_qualification|
        if /^\s+/ =~ application_qualification.qualification_type ||
           /\s+$/ =~ application_qualification.qualification_type
          application_qualification.update!(
            qualification_type: application_qualification.qualification_type.strip,
          )
        end
      end
    end
  end
end
