module QualificationAPIData
  def qualifications
    {
      gcses: format_gcses,
      degrees: format_degrees,
      other_qualifications: qualifications_of_level('other').map { |q| qualification_to_hash(q) },
      missing_gcses_explanation: application_choice.missing_gcses_explanation(separator_string: "\n\n"),
    }
  end

  def format_gcses
    gcses = qualifications_of_level('gcse').reject(&:missing_qualification?)

    # This is to split structured GCSEs in to separate GCSE qualifications for the API
    # Science triple award grades are already properly formatted and so are left out here
    to_structure, already_structured = gcses.partition do |gcse|
      gcse[:subject] != ApplicationQualification::SCIENCE_TRIPLE_AWARD && gcse[:constituent_grades].present?
    end

    separated_gcse_hashes = to_structure.flat_map { |q| structured_gcse_to_hashes(q) }
    other_gcses_hashes = already_structured.map { |q| qualification_to_hash(q) }

    other_gcses_hashes + separated_gcse_hashes
  end

  def format_degrees
    qualifications_of_level('degree').map do |qualification|
      qualification_hash = qualification_to_hash(qualification)
      sanitized_institution_name = qualification_hash[:institution_details].gsub(/, GB\z/, '')
      grade = Hesa::Grade.find_by_description(qualification_hash[:grade])
      subject = Hesa::Subject.find_by_name(qualification_hash[:subject])
      institution = Hesa::Institution.find_by_name(sanitized_institution_name)
      degree_type = Hesa::DegreeType.find_by_abbreviation_or_name(qualification.qualification_type)
      old_grades = HESA_DEGREE_GRADES.map { |e| e[1] }

      # Backwards compatibility with the old data
      # Send the synonym instead of the new data.
      # "First class honours" (old data & synonym) vs "First-class honours" (new
      # data)
      # For the data that are in both new and old this line is
      # skipped (e.g "Upper second-class honours (2:1)")
      #
      # Once the Vendor & Register team uses the UUIDs we can delete this line
      qualification_hash[:grade] = grade.synonyms.first if grade.present? && grade.synonyms.present? && !grade.name.in?(old_grades)

      if include_degree_uuids?
        qualification_hash.merge(
          {
            subject_uuid: subject&.id,
            degree_type_uuid: degree_type&.id,
            grade_uuid: grade&.id,
            institution_uuid: institution&.id,
          },
        )
      else
        qualification_hash
      end
    end
  end

  def include_degree_uuids?
    false
  end

  def include_completing_qualification?
    false
  end

  def exclude_completing_qualification?
    !include_completing_qualification?
  end

  def qualifications_of_level(level)
    application_form.application_qualifications.select do |qualification|
      qualification.level == level
    end
  end

  def qualification_to_hash(qualification)
    {
      id: qualification.public_id,
      qualification_type: qualification.qualification_type&.truncate(
        ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH,
      ),
      non_uk_qualification_type: qualification.non_uk_qualification_type&.truncate(
        ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH,
      ),
      subject: qualification.subject,
      subject_code: subject_code(qualification),
      grade: grade_details(qualification),
      start_year: qualification.start_year,
      award_year: qualification.award_year,
      institution_details: institution_details(qualification),
      awarding_body: nil,
      equivalency_details: qualification.composite_equivalency_details,
    }
    .merge(HesaQualificationFieldsPresenter.new(qualification).to_hash)
    .merge(completing_qualification(qualification))
  end

  def subject_code(qualification)
    if qualification.gcse?
      subject_code_for_gcse(qualification.subject)
    elsif qualification.other?
      subject_code_for_other_qualification(qualification)
    end
  end

  def subject_code_for_other_qualification(qualification)
    if qualification.qualification_type == 'GCSE'
      subject_code_for_gcse(qualification.subject)
    elsif ['A level', 'AS level'].include?(qualification.qualification_type)
      subject_code_for_a_levels(qualification.subject)
    end
  end

  def subject_code_for_gcse(subject)
    GCSE_SUBJECTS_TO_CODES[subject]
  end

  def subject_code_for_a_levels(subject)
    A_AND_AS_LEVEL_SUBJECTS_TO_CODES[subject]
  end

  def grade_details(qualification)
    if qualification.subject.eql?(ApplicationQualification::SCIENCE_TRIPLE_AWARD) && qualification.constituent_grades
      constituent_grades = qualification.constituent_grades

      return "#{constituent_grades['biology']['grade']}#{constituent_grades['chemistry']['grade']}#{constituent_grades['physics']['grade']}"
    elsif qualification.grade
      return qualification.predicted_grade ? "#{qualification.grade} (Predicted)" : qualification.grade
    end

    'Not entered'
  end

  def institution_details(qualification)
    if qualification.institution_name
      [qualification.institution_name,
       qualification.institution_country].compact.join(', ')
    end
  end

  def structured_gcse_to_hashes(gcse)
    constituent_grades = gcse[:constituent_grades]

    constituent_grades.inject([]) do |array, (subject, hash)|
      array << qualification_to_hash(gcse).merge(subject: subject.humanize,
                                                 subject_code: subject_code_for_gcse(subject),
                                                 grade: hash['grade'],
                                                 id: hash['public_id'])
    end
  end

private

  def completing_qualification(qualification)
    return {} if exclude_completing_qualification?

    return completing_gcse(qualification) if qualification.gcse?

    {
      other_uk_qualification_type: qualification[:other_uk_qualification_type],
    }
  end

  def completing_gcse(gcse_qualification)
    {
      currently_completing_qualification: gcse_qualification[:currently_completing_qualification],
      missing_explanation: gcse_qualification[:missing_explanation],
      other_uk_qualification_type: gcse_qualification[:other_uk_qualification_type],
    }
  end
end
