module QualificationAPIData
  def qualifications
    {
      gcses: format_gcses,
      degrees: qualifications_of_level('degree').map { |q| qualification_to_hash(q) },
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

  def qualifications_of_level(level)
    application_form.application_qualifications.select do |qualification|
      qualification.level == level
    end
  end

  def qualification_to_hash(qualification)
    {
      id: qualification.public_id,
      qualification_type: qualification.qualification_type,
      non_uk_qualification_type: qualification.non_uk_qualification_type,
      subject: qualification.subject,
      subject_code: subject_code(qualification),
      grade: grade_details(qualification),
      start_year: qualification.start_year,
      award_year: qualification.award_year,
      institution_details: institution_details(qualification),
      awarding_body: nil,
      equivalency_details: qualification.composite_equivalency_details,
    }.merge(HesaQualificationFieldsPresenter.new(qualification).to_hash)
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
end
