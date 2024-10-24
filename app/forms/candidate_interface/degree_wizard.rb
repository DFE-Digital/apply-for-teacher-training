module CandidateInterface
  class DegreeWizard
    include Wizard
    include Wizard::PathHistory

    class InvalidStepError < StandardError; end

    VALID_STEPS = %w[country subject grade type enic enic_reference degree_level completed university award_year start_year].freeze

    DEGREE_LEVEL = [
      'Foundation degree',
      'Bachelor degree',
      'Master’s degree',
      'Doctorate (PhD)',
      'Level 6 Diploma',
    ].freeze

    DOCTORATE = 'doctorate'.freeze
    DOCTORATE_LEVEL = 'Doctorate (PhD)'.freeze
    YES = 'Yes'.freeze
    NO = 'No'.freeze
    HAS_STATEMENT = 'obtained'.freeze
    OTHER = 'Other'.freeze
    NOT_APPLICABLE = 'N/A'.freeze
    UNKNOWN = 'Unknown'.freeze
    I_DO_NOT_KNOW = 'I do not know'.freeze
    QUALIFICATION_LEVEL = {
      'foundation' => 'Foundation degree',
      'bachelor' => 'Bachelor degree',
      'master' => 'Master’s degree',
      'doctor' => 'Doctorate (PhD)',
    }.freeze
    QUALIFICATION_LEVEL_MAP_OPTIONS = ActiveSupport::HashWithIndifferentAccess.new(
      {
        master: 'master’s degree',
        bachelor: 'bachelor degree',
        foundation: 'foundation degree',
        doctor: DOCTORATE,
      },
    ).freeze

    attr_accessor :uk_or_non_uk, :degree_level, :equivalent_level, :country,
                  :subject_raw, :other_type_raw, :university_raw, :other_grade_raw,
                  :type, :international_type, :grade, :completed,
                  :start_year, :award_year, :enic_reference,
                  :comparable_uk_degree, :application_form_id, :id, :recruitment_cycle_year, :path_history,
                  :return_to_application_review, :enic_reason
    attr_writer :subject, :other_type, :university, :other_grade

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
    validate(on: :grade) do |wizard|
      wizard.grade.blank?
      message =
        if wizard.specified_grades?
          I18n.t('activemodel.errors.models.candidate_interface/degree_wizard.attributes.grade.blank')
        else
          I18n.t('activemodel.errors.models.candidate_interface/degree_wizard.attributes.do_you_have_a_grade.blank')
        end
      wizard.errors.add(:grade, message) if wizard.grade.blank?
    end
    validates :other_grade, presence: true, length: { maximum: 255 }, if: :use_other_grade?, on: :grade
    validates :start_year, year: true, presence: true, on: :start_year
    validates :award_year, year: true, presence: true, on: :award_year

    validates :enic_reason, presence: true, inclusion: { in: %w[obtained waiting maybe not_needed] }, if: -> { international? }, on: :enic
    validates :enic_reference, :comparable_uk_degree, presence: true, if: -> { international? }, on: :enic_reference

    validate :award_year_is_before_start_year, on: :award_year
    validate :start_year_is_after_award_year, on: :start_year
    validate :start_year_in_future_when_degree_completed, on: :start_year
    validate :award_year_in_future_when_degree_completed, on: :award_year
    validate :award_year_in_past_when_degree_incomplete, on: :award_year
    validate :award_year_after_teacher_training_starts, on: :award_year

    def subject
      @subject_raw || @subject
    end

    def other_type
      @other_type_raw || @other_type
    end

    def university
      @university_raw || @university
    end

    def other_grade
      @other_grade_raw || @other_grade
    end

    def next_step(step = current_step)
      if !reviewing? || (reviewing? && country_changed?)
        if step == :country && uk?
          :degree_level
        elsif (step == :type && international?) || step == :degree_level
          :subject
        elsif (step == :subject && uk? && !degree_has_type?) || (step == :type && uk?) || (step == :subject && international?)
          :university
        elsif (step == :country && international? && country.present?) || (step == :subject && uk?)
          :type
        elsif step == :university
          :completed
        elsif (step == :completed && phd?) || step == :grade
          :start_year
        elsif step == :completed
          :grade
        elsif step == :start_year
          :award_year
        elsif step == :award_year && international? && completed?
          :enic
        elsif step == :enic && international? && enic_reason != HAS_STATEMENT
          :review
        elsif step == :enic && international?
          :enic_reference
        elsif %i[award_year enic enic_reference].include?(step) # rubocop:disable Lint/DuplicateBranch
          :review
        else
          raise InvalidStepError, 'Invalid Step'
        end
      elsif step == :degree_level && degree_has_type?
        :type
      elsif step == :completed
        :award_year
      elsif step == :award_year && completed? && international?
        :enic
      elsif step == :enic && international? && enic_reason != HAS_STATEMENT
        :review
      elsif step == :enic && international?
        :enic_reference
      else # rubocop:disable Lint/DuplicateBranch
        :review
      end
    end

    def back_to_review
      Rails.application.routes.url_helpers.candidate_interface_degree_review_path
    end

    def reviewing_and_unchanged_country?
      reviewing? && !country_changed?
    end

    def reviewing?
      id.present?
    end

    def reviewing_and_from_wizard_page
      reviewing? && !referer&.include?(Rails.application.routes.url_helpers.candidate_interface_degree_review_path)
    end

    def existing_degree
      ApplicationQualification.find_by(id:)
    end

    def country_changed?
      existing_degree.institution_country != country
    end

    def degree_level_back_link
      if reviewing_and_unchanged_country?
        back_to_review
      else
        Rails.application.routes.url_helpers.candidate_interface_degree_country_path
      end
    end

    def subject_back_link
      if reviewing_and_unchanged_country?
        back_to_review
      elsif international?
        Rails.application.routes.url_helpers.candidate_interface_degree_type_path
      else
        Rails.application.routes.url_helpers.candidate_interface_degree_degree_level_path
      end
    end

    def types_page_back_link
      if reviewing_and_from_wizard_page
        if international?
          Rails.application.routes.url_helpers.candidate_interface_degree_country_path
        else
          Rails.application.routes.url_helpers.candidate_interface_degree_degree_level_path
        end
      elsif !reviewing? && international?
        Rails.application.routes.url_helpers.candidate_interface_degree_country_path
      elsif !reviewing? || (reviewing? && country_changed?)
        Rails.application.routes.url_helpers.candidate_interface_degree_subject_path
      else
        back_to_review
      end
    end

    def university_back_link
      if reviewing_and_unchanged_country?
        back_to_review
      elsif degree_has_type? && uk?
        Rails.application.routes.url_helpers.candidate_interface_degree_type_path
      else
        Rails.application.routes.url_helpers.candidate_interface_degree_subject_path
      end
    end

    def start_year_back_link
      if reviewing_and_unchanged_country?
        back_to_review
      elsif phd?
        Rails.application.routes.url_helpers.candidate_interface_degree_completed_path
      else
        Rails.application.routes.url_helpers.candidate_interface_degree_grade_path
      end
    end

    def award_year_back_link
      if reviewing_and_from_wizard_page
        Rails.application.routes.url_helpers.candidate_interface_degree_completed_path
      elsif !reviewing? || (reviewing? && country_changed?)
        Rails.application.routes.url_helpers.candidate_interface_degree_start_year_path
      else
        back_to_review
      end
    end

    def enic_back_link
      if reviewing_and_from_wizard_page || !reviewing?
        Rails.application.routes.url_helpers.candidate_interface_degree_award_year_path
      else
        back_to_review
      end
    end

    def enic_reference_back_link
      if reviewing_and_from_wizard_page || !reviewing?
        Rails.application.routes.url_helpers.candidate_interface_degree_enic_path
      else
        back_to_review
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
        enic_reference: application_qualification.enic_reference,
        enic_reason: application_qualification.enic_reason,
        comparable_uk_degree: application_qualification.comparable_uk_degree,
      }

      new(degree_store, attrs)
    end

    def persist!
      existing_degree = ApplicationQualification.find_by(id:)
      if existing_degree.present?
        existing_degree.update(attributes_for_persistence)
        clear_state!
      elsif all_attributes_for_persistence_present?
        ApplicationQualification.create!(attributes_for_persistence)
        clear_state!
      end
    end

    def attributes_for_persistence
      if uk?
        {
          application_form_id:,
          level: 'degree',
          international: false,
          institution_country: country,
          qualification_type: qualification_type_attributes,
          qualification_type_hesa_code: hesa_type_code,
          qualification_level:,
          qualification_level_uuid:,
          degree_type_uuid:,
          institution_name: university,
          institution_hesa_code: hesa_institution_code,
          degree_institution_uuid:,
          subject:,
          subject_hesa_code: hesa_subject_code,
          degree_subject_uuid:,
          grade: grade_attributes,
          grade_hesa_code: hesa_grade_code,
          degree_grade_uuid:,
          predicted_grade:,
          start_year:,
          award_year:,
          enic_reference: nil,
          enic_reason: nil,
          comparable_uk_degree: nil,
        }
      else
        {
          application_form_id:,
          level: 'degree',
          international: true,
          institution_country: country,
          qualification_type: international_type,
          institution_name: university,
          subject:,
          degree_subject_uuid:,
          predicted_grade:,
          grade: other_grade || map_value_for_no_submitted_international_grade(grade),
          start_year:,
          award_year:,
          enic_reference: predicted_grade ? nil : enic_reference,
          enic_reason:,
          comparable_uk_degree: predicted_grade ? nil : comparable_uk_degree,
        }
      end
    end

    def sanitize_attrs(attrs)
      sanitize_uk_or_non_uk(attrs)
      sanitize_type(attrs)
      sanitize_degree_level(attrs)
      sanitize_grade(attrs)
      sanitize_enic(attrs)
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
      return 'Level 6 Diploma' if degree_level == 'Level 6 Diploma'

      equivalent_level || other_type || type
    end

    def grade_attributes
      return other_grade if use_other_grade?
      return 'Pass' if phd?

      grade || other_grade
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

    def other_qualification?
      degree_level == 'Another qualification equivalent to a degree'
    end

    def degree_has_type?
      ['Level 6 Diploma', 'Another qualification equivalent to a degree'].exclude?(degree_level)
    end

    def other_type_selected
      type == "Another #{degree_level.split.first.downcase} degree type"
    end

    def other_type_filled_out
      other_type.present?
    end

    def use_other_grade?
      grade == OTHER || grade == YES
    end

    def subjects
      @subjects ||= Hesa::Subject.all
    end

    def institutions
      @institutions ||= Hesa::Institution.all
    end

    def other_grades
      @other_grades ||= Hesa::Grade.other_grouping
    end

    def dynamic_type(degree_level)
      return if degree_level.nil?
      return DOCTORATE if degree_level == DOCTORATE_LEVEL

      degree_level.to_s.downcase
    end

    def bachelors?
      QUALIFICATION_LEVEL['bachelor'] == degree_level
    end

    def masters?
      QUALIFICATION_LEVEL['master'] == degree_level
    end

    def phd?
      QUALIFICATION_LEVEL['doctor'] == degree_level
    end

    def specified_grades?
      masters? || bachelors?
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

    def qualification_level
      QUALIFICATION_LEVEL.key(degree_level)
    end

    def qualification_level_uuid
      DfE::ReferenceData::Qualifications::QUALIFICATIONS.some(degree: qualification_level.to_sym).first&.id if qualification_level.present?
    end

    def award_year_is_before_start_year
      errors.add(:award_year, :before_the_start_year) if start_year.present? && award_year.to_i < start_year.to_i
    end

    def start_year_is_after_award_year
      errors.add(:start_year, :after_the_award_year) if award_year.present? && start_year.to_i > award_year.to_i
    end

    def start_year_in_future_when_degree_completed
      errors.add(:start_year, :in_the_future) if completed? && start_year.present? && start_year.to_i >= RecruitmentCycle.next_year
    end

    def award_year_in_future_when_degree_completed
      errors.add(:award_year, :in_the_future) if completed? && award_year.present? && award_year.to_i >= RecruitmentCycle.next_year
    end

    def award_year_in_past_when_degree_incomplete
      errors.add(:award_year, :in_the_past) if start_year.present? && predicted_grade && award_year.to_i < recruitment_cycle_year.to_i
    end

    def award_year_after_teacher_training_starts
      errors.add(:award_year, :after_teacher_training) if predicted_grade && award_year.to_i > recruitment_cycle_year.to_i
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

    def self.map_completed(application_qualification)
      application_qualification.predicted_grade ? NO : YES
    end

    private_class_method :map_completed

    def self.uk_type(application_qualification)
      return if application_qualification.international

      application_qualification.qualification_type if select_specific_uk_degree_type(application_qualification).present?
    end

    private_class_method :uk_type

    def self.uk_other_type(application_qualification)
      return if application_qualification.international
      return if map_to_equivalent_level(application_qualification).present?

      application_qualification.qualification_type if select_specific_uk_degree_type(application_qualification).blank?
    end

    private_class_method :uk_other_type

    def self.select_specific_uk_degree_type(application_qualification)
      CandidateInterface::DegreeTypeComponent.degree_types.values.flatten.select { |degree| degree[:name].include?(application_qualification.qualification_type) }
    end

    private_class_method :select_specific_uk_degree_type

    def self.another_degree_type_option(application_qualification)
      return if application_qualification.international
      return if map_to_equivalent_level(application_qualification).present?

      level = application_qualification.qualification_level || Hesa::DegreeType.find_by_name(application_qualification.qualification_type)&.level

      "Another #{QUALIFICATION_LEVEL_MAP_OPTIONS[level]} type"
    end

    private_class_method :another_degree_type_option

    def self.international_qualification_type(application_qualification)
      return unless application_qualification.international

      application_qualification.qualification_type
    end

    private_class_method :international_qualification_type

    def self.map_to_uk_or_non_uk(application_qualification)
      application_qualification.international ? 'non_uk' : 'uk'
    end

    private_class_method :map_to_uk_or_non_uk

    def self.select_uk_degree_level(application_qualification)
      QUALIFICATION_LEVEL[
        Hesa::DegreeType.find_by_name(application_qualification.qualification_type)&.level.to_s
      ]
    end

    private_class_method :select_uk_degree_level

    def self.map_to_degree_level(application_qualification)
      return if application_qualification.international
      return QUALIFICATION_LEVEL[application_qualification.qualification_level] if application_qualification.qualification_level
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

      CandidateInterface::DegreeGradeComponent::UK_BACHELORS_DEGREE_GRADES.find { |uk_grade| uk_grade.include?(application_qualification.grade) }.present?
    end

    private_class_method :map_to_uk_grade?

    def self.uk_grade(application_qualification)
      return if application_qualification.international

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

    def sanitize_uk_or_non_uk(attrs)
      if last_saved_state['uk_or_non_uk'] != attrs[:uk_or_non_uk] && attrs[:current_step] == :country
        attrs.merge!(degree_level: nil, equivalent_level: nil, type: nil, other_type: nil, subject: nil, completed: nil,
                     university: nil, start_year: nil, award_year: nil, international_type: nil, grade: nil,
                     other_grade: nil, enic_reason: nil, enic_reference: nil, comparable_uk_degree: nil)

      end
    end

    def sanitize_degree_level(attrs)
      if attrs[:degree_level] != 'Another qualification equivalent to a degree' && attrs[:current_step] == :degree_level
        attrs[:equivalent_level] = nil
      end
    end

    def sanitize_grade(attrs)
      if [YES, OTHER].exclude?(attrs[:grade]) && attrs[:current_step] == :grade
        attrs[:other_grade] = nil
      end
    end

    def sanitize_type(attrs)
      if attrs[:type] != "Another #{dynamic_type(last_saved_state[:degree_level])} type" && attrs[:current_step] == :type
        attrs[:other_type] = nil
        attrs[:other_type_raw] = nil
      end
    end

    def sanitize_enic(attrs)
      if attrs[:enic_reason] != HAS_STATEMENT && attrs[:current_step] == :enic
        attrs[:enic_reference] = nil
        attrs[:comparable_uk_degree] = nil
      end
    end
  end
end
