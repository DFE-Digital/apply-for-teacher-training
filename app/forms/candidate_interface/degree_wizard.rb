module CandidateInterface
  class DegreeWizard
    include Wizard

    class InvalidStepError < StandardError; end

    DEGREE_LEVEL = [
      'Foundation degree',
      'Bachelor degree',
      'Master’s degree',
      'Doctorate (PhD)',
      'Level 6 Diploma',
    ].freeze

    attr_accessor :uk_or_non_uk, :country, :degree_level, :equivalent_level, :subject,
                  :type, :international_type, :other_type, :grade, :other_grade, :university, :completed,
                  :start_year, :award_year, :have_enic_reference, :enic_reference,
                  :comparable_uk_degree, :application_form_id, :id

    validates :uk_or_non_uk, presence: true, on: :country
    validates :country, presence: true, if: :international?, on: :country
    validates :degree_level, presence: true, on: :degree_level
    validates :equivalent_level, presence: true, length: { maximum: 255 }, if: :other_qualification?, on: :degree_level
    validates :subject, presence: true, length: { maximum: 255 }, on: :subject
    validates :type, presence: true, if: :uk?, on: :type
    validates :international_type, presence: true, length: { maximum: 255 }, if: :international?, on: :type
    validates :other_type, presence: true, length: { maximum: 255 }, if: %i[uk? other_type_selected], on: :type
    validates :university, presence: true, on: :university
    validates :completed, presence: true, on: :completed
    validates :grade, presence: true, on: :grade
    validates :other_grade, presence: true, length: { maximum: 255 }, if: :grade_choices, on: :grade
    validates :start_year, presence: true, on: :start_year
    validates :award_year, presence: true, on: :award_year
    validates :have_enic_reference, presence: true, if: :international?, on: :enic
    validates :enic_reference, :comparable_uk_degree, presence: true, if: -> { have_enic_reference == 'yes' && international? }, on: :enic

    validate :award_year_is_before_start_year, on: :award_year
    validate :start_year_is_after_award_year, on: :start_year

    def next_step(step = current_step)
      if step == :country && uk_or_non_uk == 'uk'
        :degree_level
      elsif (step == :country && international? && country.present?) || step == :degree_level
        :subject
      elsif (step == :subject && uk? && level_options?) || step == :type
        :university
      elsif step == :subject
        :type
      elsif step == :university
        :completed
      elsif step == :completed
        :grade
      elsif step == :grade
        :start_year
      elsif step == :start_year
        :award_year
      elsif step == :award_year && international? && completed?
        :enic
      elsif step == :award_year || (step == :enic && international?)
        :review
      else
        raise InvalidStepError, 'Invalid Step'
      end
    end

    def self.from_application_qualification(degree_store, application_qualification)
      attrs = {
        id: application_qualification.id,
        uk_or_non_uk: map_to_uk_or_non_uk(application_qualification),
        country: application_qualification.institution_country,
        application_form_id: application_qualification.application_form_id,
        degree_level: map_to_degree_level(application_qualification),
        equivalent_level: map_to_equivalent_level(application_qualification),
        type: uk_type(application_qualification) || another_degree_type_option(application_qualification),
        international_type: international_qualification_type(application_qualification),
        other_type: uk_other_type(application_qualification),
        grade: uk_grade(application_qualification) || international_grade(application_qualification),
        other_grade: uk_other_grade(application_qualification) || international_other_grade(application_qualification),
        completed: map_completed(application_qualification),
        subject: application_qualification.subject,
        university: application_qualification.institution_name,
        start_year: application_qualification.start_year,
        award_year: application_qualification.award_year,
        have_enic_reference: map_to_have_enic_reference(application_qualification),
        enic_reference: application_qualification.enic_reference,
        comparable_uk_degree: application_qualification.comparable_uk_degree,
      }

      new(degree_store, attrs)
    end

    def persist!
      existing_degree = ApplicationQualification.find_by(id: id)
      if existing_degree.present?
        existing_degree.update(attributes_for_persistence)
      else
        ApplicationQualification.create!(attributes_for_persistence)
      end
      clear_state!
    end

    def attributes_for_persistence
      if uk?
        {
          application_form_id: application_form_id,
          level: 'degree',
          international: false,
          qualification_type: qualification_type_attributes,
          qualification_type_hesa_code: hesa_type_code(qualification_type_attributes),
          institution_name: university,
          institution_hesa_code: hesa_institution_code(university),
          subject: subject,
          subject_hesa_code: hesa_subject_code(subject),
          grade: grade_attributes,
          grade_hesa_code: hesa_grade_code(grade_attributes),
          predicted_grade: predicted_grade,
          start_year: start_year,
          award_year: award_year,
        }
      else
        {
          application_form_id: application_form_id,
          level: 'degree',
          international: true,
          institution_country: country,
          qualification_type: international_type,
          institution_name: university,
          subject: subject,
          predicted_grade: predicted_grade,
          grade: other_grade || map_value_for_no_submitted_international_grade(grade),
          start_year: start_year,
          award_year: award_year,
          enic_reference: enic_reference,
          comparable_uk_degree: comparable_uk_degree,
        }
      end
    end

    def sanitize_attrs(attrs)
      sanitize_uk_or_non_uk(attrs)
      sanitize_country(attrs)
      sanitize_type(attrs)
      sanitize_degree_level(attrs)
      sanitize_grade(attrs)
      sanitize_enic(attrs)
      attrs
    end

    def international?
      uk_or_non_uk == 'non_uk'
    end

    def hesa_institution_code(institution_name)
      Hesa::Institution.find_by_name(institution_name)&.hesa_code
    end

    def hesa_type_code(type_description)
      Hesa::DegreeType.find_by_name(type_description)&.hesa_code
    end

    def hesa_subject_code(subject)
      Hesa::Subject.find_by_name(subject)&.hesa_code
    end

    def hesa_grade_code(grade)
      Hesa::Grade.find_by_description(grade)&.hesa_code
    end

    def qualification_type_attributes
      return 'Level 6 Diploma' if degree_level == 'Level 6 Diploma'

      equivalent_level || other_type || type
    end

    def grade_attributes
      return other_grade if grade == 'Other'

      grade || other_grade
    end

    def predicted_grade
      completed == 'No'
    end

    def completed?
      completed == 'Yes'
    end

    def uk?
      uk_or_non_uk == 'uk'
    end

    def other_qualification?
      degree_level == 'Another qualification equivalent to a degree'
    end

    def level_options?
      ['Level 6 Diploma', 'Another qualification equivalent to a degree'].include?(degree_level)
    end

    def other_type_selected
      type == "Another #{degree_level.split.first.downcase} degree type"
    end

    def other_type_filled_out
      other_type.present?
    end

    def grade_choices
      grade == 'Other' || grade == 'Yes'
    end

    def subjects
      @subjects ||= Hesa::Subject.names
    end

    def institutions
      @institutions ||= Hesa::Institution.names
    end

    def dynamic_type(degree_level)
      return if degree_level.nil?
      return 'doctorate' if degree_level == 'Doctorate (PhD)'

      degree_level.to_s.to_s.downcase
    end

  private

    def award_year_is_before_start_year
      errors.add(:award_year, :before_the_start_year) if start_year.present? && award_year.to_i < start_year.to_i
    end

    def start_year_is_after_award_year
      errors.add(:start_year, :after_the_award_year) if award_year.present? && start_year.to_i > award_year.to_i
    end

    def map_value_for_no_submitted_international_grade(grade)
      self.grade = {
        'No' => 'N/A',
        'I do not know' => 'Unknown',
      }[grade]
    end

    def self.map_completed(application_qualification)
      {
        true => 'Yes',
        false => 'No',
      }[!application_qualification.predicted_grade]
    end

    private_class_method :map_completed

    def self.uk_type(application_qualification)
      return if application_qualification.international == true

      application_qualification.qualification_type if select_specific_uk_degree_type(application_qualification).present?
    end

    private_class_method :uk_type

    def self.uk_other_type(application_qualification)
      return if application_qualification.international == true
      return if map_to_equivalent_level(application_qualification).present?

      application_qualification.qualification_type if select_specific_uk_degree_type(application_qualification).blank?
    end

    private_class_method :uk_other_type

    def self.select_specific_uk_degree_type(application_qualification)
      CandidateInterface::DegreeTypeComponent::DEGREE_TYPES.select { |_general_type, specific_type| specific_type.include?(application_qualification.qualification_type) }
    end

    private_class_method :select_specific_uk_degree_type

    def self.another_degree_type_option(application_qualification)
      return if application_qualification.international == true
      return if map_to_equivalent_level(application_qualification).present?

      "Another #{application_qualification.qualification_type.split.first.downcase} degree type"
    end

    private_class_method :another_degree_type_option

    def self.international_qualification_type(application_qualification)
      return if application_qualification.international == false

      application_qualification.qualification_type
    end

    private_class_method :international_qualification_type

    def self.map_to_uk_or_non_uk(application_qualification)
      application_qualification.international == true ? 'non_uk' : 'uk'
    end

    private_class_method :map_to_uk_or_non_uk

    def self.select_uk_degree_level(application_qualification)
      DEGREE_LEVEL.select { |type| type.include?(application_qualification.qualification_type.split.first) }.join
    end

    private_class_method :select_uk_degree_level

    def self.map_to_degree_level(application_qualification)
      return if application_qualification.international == true
      return 'Level 6 Diploma' if application_qualification.qualification_type == 'Level 6 Diploma'

      select_uk_degree_level(application_qualification).presence || equivalent_or_degree_level(application_qualification)
    end

    private_class_method :map_to_degree_level

    def self.equivalent_or_degree_level(application_qualification)
      find_degree_level = select_specific_uk_degree_type(application_qualification).map(&:first).join

      find_degree_level.presence || find_degree_level.gsub('', 'Another qualification equivalent to a degree')
    end

    private_class_method :equivalent_or_degree_level

    def self.map_to_equivalent_level(application_qualification)
      if map_to_degree_level(application_qualification) == 'Another qualification equivalent to a degree'
        application_qualification.qualification_type
      end
    end

    private_class_method :map_to_equivalent_level

    def self.uk_other_grade(application_qualification)
      return if application_qualification.international == true

      unless map_to_uk_grade?(application_qualification)
        application_qualification.grade
      end
    end

    private_class_method :uk_other_grade

    def self.international_other_grade(application_qualification)
      return if application_qualification.international == false

      unless %w[N/A Unknown].include?(application_qualification.grade)
        application_qualification.grade
      end
    end

    private_class_method :international_other_grade

    def self.map_to_uk_grade?(application_qualification)
      CandidateInterface::DegreeGradeComponent::UK_DEGREE_GRADES.find { |uk_grade| uk_grade.include?(application_qualification.grade) }.present?
    end

    private_class_method :map_to_uk_grade?

    def self.uk_grade(application_qualification)
      return if application_qualification.international == true

      if map_to_uk_grade?(application_qualification)
        application_qualification.grade
      else
        'Other'
      end
    end

    private_class_method :uk_grade

    def self.international_grade(application_qualification)
      return if application_qualification.international == false
      return 'I do not know' if application_qualification.grade == 'Unknown'
      return 'No' if application_qualification.grade == 'N/A'

      'Yes'
    end

    private_class_method :international_grade

    def self.map_to_have_enic_reference(application_qualification)
      return if application_qualification.international == false

      application_qualification.enic_reference.present? ? 'yes' : 'no'
    end

    private_class_method :map_to_have_enic_reference

    def sanitize_uk_or_non_uk(attrs)
      if last_saved_state['uk_or_non_uk'] != attrs[:uk_or_non_uk] && attrs[:current_step] == :country
        attrs.merge!(degree_level: nil, equivalent_level: nil, type: nil, other_type: nil, subject: nil, completed: nil,
                     university: nil, start_year: nil, award_year: nil, international_type: nil, grade: nil,
                     other_grade: nil, have_enic_reference: nil, enic_reference: nil, comparable_uk_degree: nil)

      end
    end

    def sanitize_country(attrs)
      if attrs[:uk_or_non_uk] == 'uk' && attrs[:current_step] == :country
        attrs[:country] = nil
      end
    end

    def sanitize_degree_level(attrs)
      if attrs[:degree_level] != 'Another qualification equivalent to a degree' && attrs[:current_step] == :degree_level
        attrs[:equivalent_level] = nil
      end
    end

    def sanitize_grade(attrs)
      if %w[Yes Other].exclude?(attrs[:grade]) && attrs[:current_step] == :grade
        attrs[:other_grade] = nil
      end
    end

    def sanitize_type(attrs)
      if attrs[:type] != "Another #{dynamic_type(last_saved_state[:degree_level])} type" && attrs[:current_step] == :type
        attrs[:other_type] = nil
      end
    end

    def sanitize_enic(attrs)
      if attrs[:have_enic_reference] == 'no' && attrs[:current_step] == :enic
        attrs[:enic_reference] = nil
        attrs[:comparable_uk_degree] = nil
      end
    end
  end
end
