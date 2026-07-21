class InspectInternationalGcseGrade
  attr_reader :qualification

  def initialize(qualification)
    @qualification = qualification
  end

  def likely_below?
    structured_grade_data_available? &&
      qualification.grade.in?(likely_below_level_four)
  end

  def structured_grade_data_available?
    equivalent_qualification.present?
  end

  def requires_grade_schema_selection?
    multiple_grade_schemas_available? ||
      percentage_grade_schema_available?
  end

private

  def multiple_grade_schemas_available?
    grade_schemas.many?
  end

  def percentage_grade_schema_available?
    grade_schemas.any? do |schema|
      schema.description == 'Percentage'
    end
  end

  def likely_below_level_four
    selected_schema&.likely_below_level_four || []
  end

  def grades
    return [] if selected_schema.blank?

    selected_schema.likely_above_level_four + selected_schema.likely_below_level_four
  end

  def equivalent_qualification
    @equivalent_qualification ||= finder.equivalent_qualifications.find do |qual|
      qual.name == qualification.non_uk_qualification_type
    end
  end

  def grade_schemas
    equivalent_qualification&.grade_schemas || []
  end

  def selected_schema
    @selected_schema ||=
      if qualification.selected_grade_schema_id.present?
        grade_schemas.find do |schema|
          schema.id == qualification.selected_grade_schema_id
        end
      elsif grade_schemas.one?
        grade_schemas.first
      end
  end

  def finder
    @finder ||= InternationalQualifications::StructuredGcseOptionFinder.new(qualification.institution_country, qualification.subject)
  end
end
