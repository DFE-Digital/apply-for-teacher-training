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

  def multiple_grade_schemas_available?
    equivalent_qualification.present? &&
      equivalent_qualification.grade_schemas.many?
  end

private

  def failing_grades
    selected_schema&.failing_grades || []
  end

  def grades
    return [] if selected_schema.blank?

    selected_schema.passing_grades + selected_schema.failing_grades
  end

  def equivalent_qualification
    @equivalent_qualification ||= finder.equivalent_qualifications.find do |qual|
      qual.name == qualification.non_uk_qualification_type
    end
  end

  def selected_schema
    @selected_schema ||=
      if qualification.selected_grade_schema_id.present?
        equivalent_qualification.grade_schemas.find do |schema|
          schema.id == qualification.selected_grade_schema_id
        end
      elsif equivalent_qualification.grade_schemas.one?
        equivalent_qualification.grade_schemas.first
      end
  end

  def finder
    @finder ||= InternationalQualifications::StructuredGcseOptionFinder.new(qualification.institution_country, qualification.subject)
  end
end
