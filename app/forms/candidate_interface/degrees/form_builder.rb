module CandidateInterface
  class Degrees::FormBuilder
    include CandidateInterface::Degrees::FormConstants

    attr_reader :application_qualification
    def initialize(application_qualification)
      @application_qualification = application_qualification
    end

    def attrs
      {
        id: application_qualification.id,
        uk_or_non_uk: application_qualification.international ? 'non_uk' : 'uk',
        country: application_qualification.institution_country,
        application_form_id: application_qualification.application_form_id,
        degree_level: map_to_degree_level,
        equivalent_level: map_to_equivalent_level,
        type: map_to_degree_type,
        other_type: map_to_other_degree_type,
        grade: uk_grade || international_grade,
        other_grade: uk_other_grade || international_other_grade,
        completed: application_qualification.predicted_grade ? NO : YES,
        subject: application_qualification.subject,
        university: application_qualification.institution_name,
        start_year: application_qualification.start_year,
        award_year: application_qualification.award_year,
        enic_reference: application_qualification.enic_reference,
        enic_reason: application_qualification.enic_reason,
        comparable_uk_degree: application_qualification.comparable_uk_degree,
      }
    end

    def map_to_degree_type
      return nil if map_to_equivalent_level.present?

      if select_specific_uk_degree_type.present? || application_qualification.international
        application_qualification.qualification_type
      else
        'other'
      end
    end

    def map_to_other_degree_type
      return nil if map_to_equivalent_level.present?

      if map_to_degree_type == 'other' || map_to_degree_type.nil?
        application_qualification.qualification_type
      end
    end

    def select_specific_uk_degree_type
      CandidateInterface::DegreeTypeComponent.degree_types.values.flatten.select do |degree|
        degree[:name].include?(application_qualification.qualification_type)
      end
    end

    def map_to_equivalent_level
      if map_to_degree_level == 'other'
        application_qualification.qualification_type
      end
    end

    def map_to_degree_level
      if application_qualification.qualification_level&.in?(QUALIFICATION_LEVEL.keys)
        application_qualification.qualification_level
      elsif application_qualification.qualification_type == 'Level 6 Diploma'
        application_qualification.qualification_type
      elsif !application_qualification.international
        'other'
      end
    end

    def uk_grade
      if map_to_uk_grade?
        application_qualification.grade
      elsif !application_qualification.international
        OTHER_GRADE
      end
    end

    def international_other_grade
      return unless application_qualification.international

      unless [NOT_APPLICABLE, UNKNOWN].include?(application_qualification.grade)
        application_qualification.grade
      end
    end

    def uk_other_grade
      return if application_qualification.international
      return if map_to_uk_grade?

      application_qualification.grade
    end

    def select_uk_degree_level
      QUALIFICATION_LEVEL[
        Hesa::DegreeType.find_by_name(application_qualification.qualification_type)&.level.to_s,
      ]
    end

    def map_to_uk_grade?
      return false if application_qualification.grade.nil?

      grades = UK_BACHELORS_DEGREE_GRADES + UK_MASTERS_DEGREE_GRADES
      grades.find { |uk_grade| uk_grade.include?(application_qualification.grade) }.present?
    end

    def international_grade
      return unless application_qualification.international
      return I_DO_NOT_KNOW if application_qualification.grade == UNKNOWN
      return NO if application_qualification.grade == NOT_APPLICABLE

      YES
    end
  end
end
