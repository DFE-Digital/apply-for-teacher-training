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

  def multiple_grade_schemas_available?
    equivalent_qualification.present? &&
      equivalent_qualification.grade_schemas.many?
  end

private

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
