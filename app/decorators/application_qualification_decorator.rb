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

  def formatted_degree_and_grade
    return nil unless qualification.degree?

    subject = degree_type_and_subject
    grade = formatted_grade

    [subject, grade].compact.join(', ')
  end

private

  def formatted_grade
    return nil if qualification.grade.blank?

    short_form = grade_short_form(qualification.grade)

    if qualification.predicted_grade?
      "#{short_form} (predicted)"
    else
      short_form
    end
  end

  def grade_short_form(full_grade)
    {
      'First-class honours' => 'First',
      'Upper second-class honours (2:1)' => '2:1',
      'Lower second-class honours (2:2)' => '2:2',
      'Third-class honours' => '3rd',
    }[full_grade] || full_grade
  end

  def degree_type_and_subject
    "#{degree_type_with_honours} #{qualification.subject.titleize}"
  end

  def degree_type_with_honours
    if qualification.grade&.include?('honours')
      "#{abbreviate_degree(qualification.qualification_type)} (Hons)"
    else
      abbreviate_degree(qualification.qualification_type)
    end
  end

  def abbreviate_degree(name)
    Hesa::DegreeType.find_by_name(name)&.abbreviation || name
  end
end
