module CandidateInterface
  class Degrees::BaseForm
    include Wizard
    include CandidateInterface::Degrees::FormConstants

    attr_accessor :uk_or_non_uk, :country,
                  :degree_level, :equivalent_level,
                  :other_type, :other_type_raw, :type,
                  :subject, :subject_raw,
                  :university, :university_raw,
                  :other_grade_raw, :other_grade, :grade,
                  :completed,
                  :start_year, :award_year, :enic_reference,
                  :comparable_uk_degree, :application_form_id, :id, :path_history,
                  :return_to_application_review, :enic_reason

    def structured_degree_data?
      uk? || (country_with_compatible_degrees? && bachelors?)
    end

    def skips_type_step?
      other_uk_qualification? || degree_level == 'Level 6 Diploma'
    end

    def reviewing_and_unchanged_country?
      reviewing? && existing_degree&.institution_country == country
    end

    def reviewing?
      id.present?
    end

    def existing_degree
      ApplicationQualification.find_by(id:)
    end

    def self.from_application_qualification(degree_store, application_qualification)
      form_builder = Degrees::FormBuilder.new(application_qualification)

      new(degree_store, form_builder.attrs)
    end

    def persist!
      existing_degree = ApplicationQualification.find_by(id:)
      if existing_degree.present? && all_attributes_for_persistence_present?
        existing_degree.update(attributes_for_persistence)
        clear_state!
      elsif all_attributes_for_persistence_present?
        ApplicationQualification.create!(attributes_for_persistence)
        clear_state!
      end
    end

    def attributes_for_persistence
      {
        application_form_id:,
        level: 'degree',
        international: !uk?,
        institution_country: country,
        qualification_level: degree_level_attribute,
        qualification_level_uuid: structured_degree_data? ? qualification_level_uuid : nil,
        qualification_type: qualification_type_attributes,
        qualification_type_hesa_code: structured_degree_data? ? hesa_type_code : nil,
        degree_type_uuid: structured_degree_data? ? degree_type_uuid : nil,
        institution_name: university_raw || university,
        institution_hesa_code: hesa_institution_code,
        degree_institution_uuid:,
        subject: subject_raw || subject,
        subject_hesa_code: structured_degree_data? ? hesa_subject_code : nil,
        degree_subject_uuid:,
        grade: structured_degree_data? ? grade_attributes : (other_grade || map_value_for_no_submitted_international_grade(grade)),
        grade_hesa_code: structured_degree_data? ? hesa_grade_code : nil,
        degree_grade_uuid: structured_degree_data? ? degree_grade_uuid : nil,
        predicted_grade:,
        start_year:,
        award_year:,
        enic_reason:,
        enic_reference: enic_reference_must_be_nil? ? nil : enic_reference,
        comparable_uk_degree: enic_reference_must_be_nil? ? nil : comparable_uk_degree,
      }
    end

    def sanitize_attrs(attrs)
      attrs
    end

    def international?
      uk_or_non_uk == 'non_uk'
    end

    def hesa_institution_code
      hesa_institution&.hesa_code
    end

    def hesa_type_code
      hesa_type&.hesa_code
    end

    def hesa_subject_code
      hesa_subject&.hesa_code
    end

    def hesa_grade_code
      hesa_grade&.hesa_code
    end

    def degree_institution_uuid
      hesa_institution&.id
    end

    def degree_type_uuid
      hesa_type&.id
    end

    def degree_subject_uuid
      hesa_subject&.id
    end

    def degree_grade_uuid
      hesa_grade&.id
    end

    def qualification_type_attributes
      if degree_level == 'Level 6 Diploma'
        'Level 6 Diploma'
      else
        equivalent_level || other_type_raw || other_type || type
      end
    end

    def degree_level_attribute
      if degree_level.present? && degree_level.in?(QUALIFICATION_LEVEL.keys)
        degree_level
      end
    end

    def grade_attributes
      if phd?
        'Pass'
      else
        other_grade_raw || other_grade || grade
      end
    end

    def predicted_grade
      completed == NO
    end

    def enic_reference_must_be_nil?
      predicted_grade || uk? || (enic_reason != 'obtained')
    end

    def completed?
      completed == YES
    end

    def uk?
      uk_or_non_uk == 'uk'
    end

    def country_with_compatible_degrees?
      country.in? ApplicationQualification::COUNTRIES_WITH_COMPATIBLE_DEGREES.keys
    end

    def other_uk_qualification?
      uk? && degree_level == 'other'
    end

    def bachelors?
      degree_level == 'bachelor'
    end

    def masters?
      degree_level == 'master'
    end

    def phd?
      degree_level == 'doctor'
    end

  private

    def hesa_institution
      Hesa::Institution.find_by_name(university)
    end

    def hesa_type
      Hesa::DegreeType.find_by_name(qualification_type_attributes)
    end

    def hesa_subject
      Hesa::Subject.find_by_name(subject)
    end

    def hesa_grade
      Hesa::Grade.find_by_description(grade_attributes)
    end

    def qualification_level_uuid
      if degree_level.present?
        DfE::ReferenceData::Qualifications::QUALIFICATIONS.some(degree: degree_level.to_sym).first&.id
      end
    end

    def map_value_for_no_submitted_international_grade(grade)
      return grade if grade.in? [NOT_APPLICABLE, UNKNOWN]

      self.grade = {
        NO => NOT_APPLICABLE,
        I_DO_NOT_KNOW => UNKNOWN,
      }[grade]
    end

    def all_attributes_for_persistence_present?
      attributes_for_persistence.slice(
        :qualification_type, :institution_name, :subject, :grade, :start_year, :award_year
      ).values.all?(&:present?)
    end

    def paths
      @paths ||= Rails.application.routes.url_helpers
    end
  end
end
