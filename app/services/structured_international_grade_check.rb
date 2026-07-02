class StructuredInternationalGradeCheck
  attr_reader :qualification

  def initialize(qualification)
    @qualification = qualification
  end

  def passing?
    return true unless structured_grade_data_available?
    return true unless qualification.grade.in?(grades)

    qualification.grade.in?(passing_grades)
  end

  def structured_grade_data_available?
    equivalent_qualification.present?
  end

private

  def passing_grades
    finder
      .grade_schemas(equivalent_qualification)
      .first
      &.passing_grades || []
  end

  def grades
    # TODO: Make a grades method in the reference data
    schema = finder.grade_schemas(equivalent_qualification).first

    (schema&.passing_grades || []) + (schema&.failing_grades || [])
  end

  def equivalent_qualification
    @equivalent_qualification ||= finder.equivalent_qualifications.find do |qual|
      qual.name == qualification.non_uk_qualification_type
    end
  end

  def finder
    @finder ||= InternationalQualifications::StructuredGcseOptionFinder.new(
      qualification.institution_country,
    )
  end
end
