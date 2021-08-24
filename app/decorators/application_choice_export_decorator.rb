class ApplicationChoiceExportDecorator < SimpleDelegator
  RELEVANT_SUBJECTS = [
    ApplicationQualification::MATHS,
    ApplicationQualification::ENGLISH,
    ApplicationQualification::SCIENCE,
    ApplicationQualification::SCIENCE_SINGLE_AWARD,
    ApplicationQualification::SCIENCE_DOUBLE_AWARD,
    ApplicationQualification::SCIENCE_TRIPLE_AWARD,
  ].freeze

  def gcse_qualifications_summary
    application_form
      .application_qualifications
      .select { |qualification| qualification.level == 'gcse' && RELEVANT_SUBJECTS.include?(qualification.subject) }
      .map { |gcse| summary_for_gcse(gcse) }
      .join(',')
      .presence
  end

  def missing_gcses_explanation(separator_string: ',')
    application_form
      .application_qualifications
      .select { |qualification| qualification.level == 'gcse' }
      .select(&:missing_qualification?)
      .map { |gcse| "#{gcse.subject.capitalize} GCSE or equivalent: #{gcse.missing_explanation}" }
      .join(separator_string)
      .presence
  end

  def degrees_completed_flag
    application_form.degrees_completed ? 1 : 0
  end

  def first_degree
    application_form
      .application_qualifications
      .select { |qualification| qualification.level == 'degree' }
      .min_by(&:created_at)
  end

  def nationalities
    [
      application_form.first_nationality,
      application_form.second_nationality,
      application_form.third_nationality,
      application_form.fourth_nationality,
      application_form.fifth_nationality,
    ].map { |n| NATIONALITIES_BY_NAME[n] }.compact.uniq
      .sort.partition { |e| %w[GB IE].include? e }.flatten
  end

private

  def missing_gcse_explanation(gcse)
    "#{gcse.subject.capitalize} GCSE or equivalent: #{gcse.missing_explanation}"
  end

  def summary_for_gcse(gcse)
    return if gcse.blank?

    "#{gcse.qualification_type.humanize} #{gcse.subject.capitalize}, #{gcse.grade}, #{gcse.start_year}-#{gcse.award_year}"
  end
end
