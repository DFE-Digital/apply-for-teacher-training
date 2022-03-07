module DataMigrations
  class BackfillDegreesNewData
    TIMESTAMP = 20220307165548
    MANUAL_RUN = false

    def change
      ApplicationQualification.degree.find_each do |qualification|
        degree_type = DfE::ReferenceData::Degrees::TYPES.some(abbreviation: qualification.qualification_type).first
        institution = DfE::ReferenceData::Degrees::INSTITUTIONS.all.find { |institution| institution.name == qualification.institution_name || institution.match_synonyms.include?(qualification.institution_name) }
        subject = DfE::ReferenceData::Degrees::SUBJECTS.some(name: qualification.subject).first
        grade = DfE::ReferenceData::Degrees::GRADES.all.find { |grade| qualification.grade.in?(grade.synonyms) }

        if [degree_type, institution, subject, grade].any?
          qualification.update(
            degree_type_uuid: degree_type&.id,
            degree_institution_uuid: institution&.id,
            degree_subject_uuid: subject&.id,
            degree_grade_uuid: grade&.id
          )
        end
      end
    end
  end
end
