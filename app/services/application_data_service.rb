class ApplicationDataService
  def self.gcse_qualifications_summary(application_form:)
    gcses = %i[maths_gcse english_gcse science_gcse]
    summary_string = gcses
      .map { |gcse| application_form.send(gcse) }
      .map { |gcse| summary_for_gcse(gcse) }
      .compact
      .join(',')

    summary_string.presence
  end

  def self.missing_gcses_explanation(application_form:)
    gcses = application_form.application_qualifications.select do |q|
      q.level == 'gcse'
    end

    explanation = gcses
                    .select(&:missing_qualification?)
                    .map { |gcse| "#{gcse.subject.capitalize} GCSE or equivalent: #{gcse.missing_explanation}" }
                    .join(',')

    explanation.presence
  end

  def self.summary_for_gcse(gcse)
    "#{gcse.qualification_type.humanize} #{gcse.subject.capitalize}, #{gcse.grade}, #{gcse.start_year}-#{gcse.award_year}" if gcse.present?
  end

  def self.degrees_completed(application_form:)
    application_form.degrees_completed ? 1 : 0
  end

  def self.composite_equivalency_details(qualification:)
    return if qualification.nil?

    details = [
      ("Naric: #{qualification.naric_reference}" if qualification.naric_reference),
      qualification.comparable_uk_qualification,
      qualification.equivalency_details,
    ].compact.join(' - ')

    details.strip if details.present?
  end
end
