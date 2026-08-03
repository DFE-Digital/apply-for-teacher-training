module InternationalGradeBuilder
  def finder
    return if institution_country.blank?

    @finder ||= InternationalQualifications::StructuredGcseOptionFinder.new(institution_country, subject)
  end

  def selected_equivalent_qualification
    return if non_uk_qualification_type.blank? || finder.blank?

    finder.equivalent_qualifications.find do |qualification|
      qualification.name == non_uk_qualification_type
    end
  end

  def grade_schemas
    @grade_schemas ||= selected_equivalent_qualification&.grade_schemas
  end

  def selected_grade_schema
    @selected_grade_schema ||=
      if qualification.selected_grade_schema_id.present?
        grade_schemas.find do |schema|
          schema.id == qualification.selected_grade_schema_id
        end
      elsif grade_schemas&.one?
        grade_schemas.first
      else
        nil
      end
  end

  def selected_grade_schema_percentage?
    @selected_grade_schema_percentage ||= selected_grade_schema&.description == 'Percentage'
  end

  def structured_grades
    @structured_grades ||=
      if selected_grade_schema.present?
        selected_grade_schema.likely_above_level_four +
          selected_grade_schema.likely_below_level_four
      else
        []
      end
  end
end
