class ApplicationQualificationDecorator < SimpleDelegator
  attr_reader :qualification

  def initialize(qualification)
    @qualification = qualification
    super
  end

  def grade_details
    return {} if qualification.missing_qualification?

    if (grades = qualification.constituent_grades).present?
      grades.each.with_object({}) do |(subject, details), hash|
        grade = details['grade'] || 'Grade information not available'
        hash[subject] = "#{grade} (#{subject.humanize})"
      end
    elsif qualification.subject == ApplicationQualification::SCIENCE_TRIPLE_AWARD
      %w[biology chemistry physics].index_with { |subject| "Grade information not available (#{subject})" }
    elsif qualification.subject == ApplicationQualification::SCIENCE_DOUBLE_AWARD
      { qualification.subject => "#{qualification.grade} (double award)" }
    elsif qualification.subject == ApplicationQualification::SCIENCE_SINGLE_AWARD
      { qualification.subject => "#{qualification.grade} (single award)" }
    else
      { qualification.subject => qualification.grade }
    end
  end
end
