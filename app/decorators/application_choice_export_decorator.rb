class ApplicationChoiceExportDecorator < SimpleDelegator
  def gcse_qualifications_summary
    required_subjects = ApplicationQualification::REQUIRED_GCSE_SUBJECTS
    summary_string = application_form
      .application_qualifications
      .select { |qualification| qualification.gcse? && required_subjects.include?(qualification.subject) }
      .sort { |a, b| required_subjects.index(b.subject) <=> required_subjects.index(a.subject) }
      .map { |gcse| summary_for_gcse(gcse) }
      .join(',')

    summary_string.presence
  end

  def missing_gcses_explanation(separator_string: ',')
    application_form
      .application_qualifications
      .select(&:gcse?)
      .select(&:missing_qualification?)
      .map { |gcse| "#{gcse.subject.capitalize} GCSE or equivalent: #{gcse.not_completed_explanation}" }
      .join(separator_string)
      .presence
  end

  def degrees_completed_flag
    application_form.degrees_completed ? 1 : 0
  end

  def first_degree
    application_form
      .application_qualifications
      .select(&:degree?)
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
    "#{gcse.subject.capitalize} GCSE or equivalent: #{gcse.not_completed_explanation}"
  end

  def summary_for_gcse(gcse)
    return if gcse.blank?

    "#{gcse.qualification_type.humanize} #{gcse.subject.capitalize}, #{gcse.grade}, #{gcse.start_year}-#{gcse.award_year}"
  end
end
