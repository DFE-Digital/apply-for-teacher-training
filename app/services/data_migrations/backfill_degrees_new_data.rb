module DataMigrations
  class BackfillDegreesNewData
    TIMESTAMP = 20220307165548
    MANUAL_RUN = true

    def change
      ApplicationQualification.degree.find_each do |qualification|
        degree_type = degree_type_for(qualification)
        institution = institution_for(qualification)
        subject = subject_for(qualification)
        grade = grade_for(qualification)

        if [degree_type, institution, subject, grade].any?
          qualification.update_columns(
            degree_type_uuid: degree_type&.id,
            degree_institution_uuid: institution&.id,
            degree_subject_uuid: subject&.id,
            degree_grade_uuid: grade&.id,
          )
        end
      end
    end

    def dry_run
      results = ApplicationQualification.degree.find_each.map do |qualification|
        degree_type = degree_type_for(qualification)
        institution = institution_for(qualification)
        subject = subject_for(qualification)
        grade = grade_for(qualification)

        {
          degree_type_uuid: degree_type&.id,
          degree_institution_uuid: institution&.id,
          degree_subject_uuid: subject&.id,
          degree_grade_uuid: grade&.id,
        }
      end

      # rubocop:disable Rails/Output
      puts "Number of Degrees: #{ApplicationQualification.degree.count}"
      puts "Degree types found: #{results.select { |result| result[:degree_type_uuid].present? }.size}"
      puts "Degree institutions found: #{results.select { |result| result[:degree_institution_uuid].present? }.size}"
      puts "Degree subject found: #{results.select { |result| result[:degree_subject_uuid].present? }.size}"
      puts "Degree grades found: #{results.select { |result| result[:degree_grade_uuid].present? }.size}"
      # rubocop:enable Rails/Output
    end

    def degree_type_for(qualification)
      DfE::ReferenceData::Degrees::TYPES.all.find do |degree_type|
        (degree_type.hesa_itt_code.present? && degree_type.hesa_itt_code == qualification.qualification_type_hesa_code) ||
          degree_type.abbreviation == qualification.qualification_type ||
          degree_type.name == qualification.qualification_type
      end
    end

    def institution_for(qualification)
      DfE::ReferenceData::Degrees::INSTITUTIONS.all.find do |institution|
        (institution.hesa_itt_code.present? && institution.hesa_itt_code == qualification.institution_hesa_code) ||
          institution.name == qualification.institution_name ||
          institution.match_synonyms.include?(qualification.institution_name)
      end
    end

    def subject_for(qualification)
      DfE::ReferenceData::Degrees::SUBJECTS.all.find do |subject|
        (subject.hesa_itt_code.present? && subject.hesa_itt_code == qualification.subject_hesa_code) ||
          subject.name == qualification.subject
      end
    end

    def grade_for(qualification)
      DfE::ReferenceData::Degrees::GRADES.all.find do |grade|
        (grade.hesa_itt_code.present? && grade.hesa_itt_code == qualification.grade_hesa_code) ||
          grade.name == qualification.grade ||
          qualification.grade.in?(grade.suggestion_synonyms) ||
          qualification.grade.in?(grade.match_synonyms)
      end
    end
  end
end
