module CandidateInterface
  class Degrees::BaseForm
    include Wizard
    include Wizard::PathHistory

    VALID_STEPS = [
      'country', # Everyone selects a country
      'degree_level', # Only UK and countries with UK-compatible degrees select a level (eg Bachelor's or Master's)
      'type', # Everyone select a type, if UK or compatible degree level, something like 'Bachelor of Science'. Free text if international
      'subject', # Everyone selects a subject
      'completed', # Everyone says if they have completed their degree
      'grade', # If the degree is a doctorate, they skip this question
      'start_year', # Everyone enters a start year
      'award_year', # Everyone enters an award year, even if it is in the future
      'university', # Everyone selects a university.
      'enic', # All international degrees, even UK-compatible ones get this question
      'enic_reference', # Only international degrees when they say they have received an enic.
    ].freeze

    YES = 'Yes'.freeze
    NO = 'No'.freeze
    OTHER = 'Other'.freeze

    UK_BACHELORS_DEGREE_GRADES = [
      'First-class honours',
      'Upper second-class honours (2:1)',
      'Lower second-class honours (2:2)',
      'Third-class honours',
      'Pass',
      'Other',
    ].freeze

    UK_MASTERS_DEGREE_GRADES = %w[Distinction Merit Pass Other].freeze
    NOT_APPLICABLE = 'N/A'.freeze
    UNKNOWN = 'Unknown'.freeze
    I_DO_NOT_KNOW = 'I do not know'.freeze
    QUALIFICATION_LEVEL = {
      'foundation' => 'Foundation degree',
      'bachelor' => 'Bachelor degree',
      'master' => 'Master’s degree',
      'doctor' => 'Doctorate (PhD)',
      'Level 6 Diploma' => 'Level 6 Diploma',
      'other' => 'Another qualification equivalent to a degree',
    }.freeze

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
      attrs = {
        id: application_qualification.id,
        uk_or_non_uk: application_qualification.international ? 'non_uk' : 'uk',
        country: application_qualification.institution_country,
        application_form_id: application_qualification.application_form_id,
        degree_level: map_to_degree_level(application_qualification),
        equivalent_level: map_to_equivalent_level(application_qualification),
        type: get_degree_type(application_qualification),
        other_type: get_other_type(application_qualification),
        grade: uk_grade(application_qualification) || international_grade(application_qualification),
        other_grade: uk_other_grade(application_qualification) || international_other_grade(application_qualification),
        completed: application_qualification.predicted_grade ? NO : YES,
        subject: application_qualification.subject,
        university: application_qualification.institution_name,
        start_year: application_qualification.start_year,
        award_year: application_qualification.award_year,
        enic_reference: application_qualification.enic_reference,
        enic_reason: application_qualification.enic_reason,
        comparable_uk_degree: application_qualification.comparable_uk_degree,
      }

      new(degree_store, attrs)
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
        qualification_level: structured_degree_data? ? degree_level : nil,
        qualification_level_uuid: structured_degree_data? ? qualification_level_uuid : nil,
        qualification_type: qualification_type_attributes,
        qualification_type_hesa_code: structured_degree_data? ? hesa_type_code : nil,
        degree_type_uuid: structured_degree_data? ? degree_type_uuid : nil,
        institution_name: university,
        institution_hesa_code: hesa_institution_code,
        degree_institution_uuid:,
        subject:,
        subject_hesa_code: structured_degree_data? ? hesa_subject_code : nil,
        degree_subject_uuid:,
        grade: structured_degree_data? ? grade_attributes : (other_grade || map_value_for_no_submitted_international_grade(grade)),
        grade_hesa_code: structured_degree_data? ? hesa_grade_code : nil,
        degree_grade_uuid: structured_degree_data? ? degree_grade_uuid : nil,
        predicted_grade:,
        start_year:,
        award_year:,
        enic_reference: predicted_grade || uk? ? nil : enic_reference,
        enic_reason:,
        comparable_uk_degree: predicted_grade || uk? ? nil : comparable_uk_degree,
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
      if degree_has_type?
        other_type_raw || other_type || type
      else
        equivalent_level || degree_level
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

    def completed?
      completed == YES
    end

    def uk?
      uk_or_non_uk == 'uk'
    end

    def country_with_compatible_degrees?
      country.in? ApplicationQualification::COUNTRIES_WITH_COMPATIBLE_DEGREES.keys
    end

    def degree_has_type?
      ['Level 6 Diploma', 'other'].exclude?(degree_level)
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

    def self.get_degree_type(application_qualification)
      if select_specific_uk_degree_type(application_qualification).present? || application_qualification.international
        application_qualification.qualification_type
      else
        OTHER
      end
    end

    private_class_method :get_degree_type

    def self.get_other_type(application_qualification)
      if select_specific_uk_degree_type(application_qualification).blank?
        application_qualification.qualification_type
      end
    end

    private_class_method :get_other_type

    def self.select_specific_uk_degree_type(application_qualification)
      CandidateInterface::DegreeTypeComponent.degree_types.values.flatten.select do |degree|
        degree[:name].include?(application_qualification.qualification_type)
      end
    end

    private_class_method :select_specific_uk_degree_type

    def self.international_qualification_type(application_qualification)
      return unless application_qualification.international

      application_qualification.qualification_type
    end

    private_class_method :international_qualification_type

    def self.select_uk_degree_level(application_qualification)
      QUALIFICATION_LEVEL[
        Hesa::DegreeType.find_by_name(application_qualification.qualification_type)&.level.to_s,
      ]
    end

    private_class_method :select_uk_degree_level

    def self.map_to_degree_level(application_qualification)
      if application_qualification.qualification_level&.in?(QUALIFICATION_LEVEL.keys)
        application_qualification.qualification_level
      end
    end

    private_class_method :map_to_degree_level

    def self.map_to_equivalent_level(application_qualification)
      if map_to_degree_level(application_qualification) == OTHER
        application_qualification.qualification_type
      end
    end

    private_class_method :map_to_equivalent_level

    def self.uk_other_grade(application_qualification)
      return if application_qualification.international

      unless map_to_uk_grade?(application_qualification)
        application_qualification.grade
      end
    end

    private_class_method :uk_other_grade

    def self.international_other_grade(application_qualification)
      return unless application_qualification.international

      unless [NOT_APPLICABLE, UNKNOWN].include?(application_qualification.grade)
        application_qualification.grade
      end
    end

    private_class_method :international_other_grade

    def self.map_to_uk_grade?(application_qualification)
      return false if application_qualification.grade.nil?

      grades = UK_BACHELORS_DEGREE_GRADES + UK_MASTERS_DEGREE_GRADES
      grades.find { |uk_grade| uk_grade.include?(application_qualification.grade) }.present?
    end

    private_class_method :map_to_uk_grade?

    def self.uk_grade(application_qualification)
      if map_to_uk_grade?(application_qualification)
        application_qualification.grade
      else
        OTHER
      end
    end

    private_class_method :uk_grade

    def self.international_grade(application_qualification)
      return unless application_qualification.international
      return I_DO_NOT_KNOW if application_qualification.grade == UNKNOWN
      return NO if application_qualification.grade == NOT_APPLICABLE

      YES
    end

    private_class_method :international_grade

    def paths
      @paths ||= Rails.application.routes.url_helpers
    end
  end
end
