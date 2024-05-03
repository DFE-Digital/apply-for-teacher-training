class ApplicationChoiceExportDecorator < SimpleDelegator
  def gcse_qualifications_summary
    required_subjects = ApplicationQualification::REQUIRED_GCSE_SUBJECTS
    summary_string = application_form
      .application_qualifications
      .select { |qualification| qualification.gcse? && required_subjects.include?(qualification.subject) }
      .sort { |a, b| required_subjects.index(b.subject) <=> required_subjects.index(a.subject) }
      .map { |gcse| summary_for_gcse(gcse) }
      .join('; ')

    summary_string.presence
  end

  def missing_gcses_explanation(separator_string: ',')
    application_form
      .application_qualifications
      .select(&:gcse?)
      .select(&:missing_qualification?)
      .map { |gcse| "#{gcse.subject.capitalize} GCSE or equivalent: #{gcse_explanation(gcse)}" }
      .join(separator_string)
      .presence
  end

  def degrees_completed_flag
    application_form.degrees_completed ? 1 : 0
  end

  def first_degree
    degree = application_form
      .application_qualifications
      .select(&:degree?)
      .min_by(&:created_at)

    DegreeHesaExportDecorator.new(degree)
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

  def rejection_reasons
    reasons = RejectedApplicationChoicePresenter.new(__getobj__).rejection_reasons
    return if reasons.nil?

    reasons = reasons.transform_values(&:compact)
    result = reasons&.map { |k, v| %(#{k.upcase}\n\n#{Array(v).join("\n\n")}) }&.join("\n\n")
    result.gsub(/^REASONS WHY YOUR APPLICATION WAS UNSUCCESSFUL\n\n/, '')
  end

  def domicile_country
    DomicileResolver.country_for_hesa_code(application_form.domicile)
  end

  def formatted_equivalency_details
    return unless first_degree

    enic_reference = "ENIC: #{first_degree.enic_reference}" if first_degree.enic_reference

    comparable_uk_qualification = first_degree.comparable_uk_qualification

    unless comparable_uk_qualification
      comparable_uk_qualification = first_degree.comparable_uk_degree
      comparable_uk_qualification = I18n.t("application_qualification.comparable_uk_degree.#{comparable_uk_qualification}") if comparable_uk_qualification
    end

    [enic_reference, comparable_uk_qualification, first_degree.equivalency_details]
      .compact
      .map(&:strip)
      .join(' - ')
  end

private

  def gcse_explanation(gcse)
    gcse.missing_explanation.presence || gcse.not_completed_explanation
  end

  def missing_gcse_explanation(gcse)
    "#{gcse.subject.capitalize} GCSE or equivalent: #{gcse_explanation(gcse)}"
  end

  def summary_for_gcse(gcse)
    return if gcse.blank?

    qualification = ApplicationQualificationDecorator.new(gcse)
    qualification_type = formatted_qualification_type(qualification.qualification_type)
    qualification_subject = formatted_qualification_subject(qualification.subject)

    "#{qualification_type} #{qualification_subject}, #{qualification.grade_details.values.join(' ')}, #{qualification_period(qualification)}"
  end

  def formatted_qualification_type(qualification_type)
    substitutions = { 'Gcse' => 'GCSE', 'Gce o' => 'O', 'Non uk' => 'Non-UK', 'Other uk' => 'Other UK' }
    qualification_type.humanize.gsub(/(Gcse|Gce o|Non uk|Other uk)/, substitutions)
  end

  def formatted_qualification_subject(subject)
    return 'English' if subject == 'english'

    subject
  end

  def qualification_period(qualification)
    [qualification.start_year, qualification.award_year].compact.join(' to ')
  end
end
