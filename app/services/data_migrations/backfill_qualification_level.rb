module DataMigrations
  class BackfillQualificationLevel
    TIMESTAMP = 20220523143800
    MANUAL_RUN = true

    def change
      records.find_each do |qualification|
        qualification_level = find_qualification_level(qualification)
        qualification_level_uuid = find_qualification_level_uuid(qualification)

        if qualification_level.present? || qualification_level_uuid.present?
          qualification.update_columns(
            qualification_level: qualification_level,
            qualification_level_uuid: qualification_level_uuid,
          )
        end
      end
    end

    # rubocop:disable Rails/Output
    def dry_run
      found = 0
      not_found = 0
      not_found_data = []

      records.find_each do |qualification|
        qualification_level = find_qualification_level(qualification)
        qualification_level_uuid = find_qualification_level_uuid(qualification)

        if qualification_level.present?
          message = "'#{qualification.qualification_type}' with #{qualification_level}"
          message << " From reference data: '#{DfE::ReferenceData::Qualifications::QUALIFICATIONS.one(qualification_level_uuid)&.name}' '#{qualification_level_uuid}'" if qualification_level_uuid.present?
          puts message
          found += 1
        else
          not_found_data << qualification.qualification_type
          not_found += 1
        end
      end

      puts "Qualification records updated: #{found} records"
      puts "Qualification records that do not have a level: #{not_found} records"
      puts "Not found data: #{not_found_data.join(', ')}"
    end
    # rubocop:enable Rails/Output

    def records
      ApplicationQualification.degree
    end

  private

    def find_qualification_level(qualification)
      degree_type_for(qualification)&.level
    end

    def find_qualification_level_uuid(qualification)
      degree_type_for(qualification)&.qualification
    end

    def degree_type_for(qualification)
      return if qualification.qualification_type.blank?

      Hesa::DegreeType.find_by_abbreviation_or_name(qualification.qualification_type) ||
        Hesa::DegreeType.find_by_hesa_code(qualification.qualification_type_hesa_code)
    end
  end
end
