class InspectInternationalGcseGrade
  attr_reader :qualification

  def initialize(qualification)
    @qualification = qualification
  end

  def failing?
    structured_grade_data_available? &&
      qualification.grade.in?(failing_grades)
  end

  def structured_grade_data_available?
    equivalent_qualification.present?
  end

private

  def failing_grades
    selected_schema.failing_grades
  end

  def grades
    selected_schema.passing_grades + selected_schema.failing_grades
  end

  def equivalent_qualification
    @equivalent_qualification ||= finder.equivalent_qualifications.find do |qual|
      qual.name == qualification.non_uk_qualification_type
    end
  end

  def selected_schema
    finder.grade_schemas(equivalent_qualification).first
  end

  def finder
    @finder ||= InternationalQualifications::StructuredGcseOptionFinder.new(qualification.institution_country)
  end
end
