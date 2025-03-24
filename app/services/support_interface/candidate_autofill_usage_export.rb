module SupportInterface
  class CandidateAutofillUsageExport
    def data_for_export(*)
      degree_grade_output +
        degree_institution_output +
        degree_subject_output +
        degree_type_output +
        other_grade_output +
        other_type_output
    end

  private

    def degree_grade_output
      create_output(
        level: :degree,
        attribute: :grade,
        field_name: 'Degree grade',
        set_to_check: degree_grades,
      )
    end

    def degree_institution_output
      create_output(
        level: :degree,
        attribute: :institution_name,
        field_name: 'Degree institution',
        set_to_check: degree_institutions,
      )
    end

    def degree_subject_output
      create_output(
        level: :degree,
        attribute: :subject,
        field_name: 'Degree subject',
        set_to_check: degree_subjects,
      )
    end

    def degree_type_output
      create_output(
        level: :degree,
        attribute: :qualification_type,
        field_name: 'Degree type',
        set_to_check: degree_types,
      )
    end

    def other_grade_output
      create_output(
        level: :other,
        attribute: :grade,
        field_name: 'Other grade',
        set_to_check: other_grades,
      )
    end

    def other_type_output
      create_output(
        level: :other,
        attribute: :qualification_type,
        field_name: 'Other type',
        set_to_check: other_types,
      )
    end

    def create_output(level:, attribute:, field_name:, set_to_check:)
      counts_for(level:, attribute:)
        .map do |value, count|
        {
          field: field_name,
          value_entered: value,
          frequency: count,
          free_text?: set_to_check.exclude?(value),
        }
      end
    end

    def counts_for(level:, attribute:)
      case level
      when :degree
        degree_qualifications
          .group(attribute)
          .count
      when :other
        other_qualifications
          .group(attribute)
          .count
      end
    end

    def degree_qualifications
      @degree_qualifications ||= qualification_query('degree')
    end

    def other_qualifications
      @other_qualifications ||= qualification_query('other')
    end

    def qualification_query(level)
      ApplicationQualification
        .joins(:application_form)
        .where(
          level:,
          application_forms: {
            phase: 'apply_1',
            recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
          },
        )
        .where(
          'application_forms.submitted_at > ?', Date.new(2020, 12, 1)
        )
        .where.not(
          qualification_type: 'non_uk',
        )
        .where.not(
          international: true,
        )
        .all
    end

    def degree_grades
      Hesa::Grade.names
    end

    def degree_institutions
      Hesa::Institution.names
    end

    def degree_subjects
      Hesa::Subject.names
    end

    def degree_types
      Hesa::DegreeType.names
    end

    def other_grades
      OTHER_UK_QUALIFICATION_GRADES
    end

    def other_types
      OTHER_UK_QUALIFICATIONS
    end
  end
end
