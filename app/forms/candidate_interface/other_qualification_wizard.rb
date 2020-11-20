module CandidateInterface
  class OtherQualificationWizard
    A_LEVEL_TYPE = 'A level'.freeze
    AS_LEVEL_TYPE = 'AS level'.freeze
    GCSE_TYPE = 'GCSE'.freeze
    OTHER_TYPE = 'Other'.freeze
    NON_UK_TYPE = 'non_uk'.freeze
    ALL_VALID_TYPES = [A_LEVEL_TYPE, AS_LEVEL_TYPE, GCSE_TYPE, OTHER_TYPE, NON_UK_TYPE].freeze

    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks
    include ValidationUtils

    attr_accessor :current_step, :current_other_qualification_id, :checking_answers
    attr_accessor :qualification_type, :other_uk_qualification_type, :non_uk_qualification_type
    attr_accessor :id, :subject, :predicted_grade, :grade, :award_year, :choice, :institution_country
    attr_reader :attrs

    PERSISTENT_ATTRIBUTES = %w[qualification_type other_uk_qualification_type non_uk_qualification_type subject predicted_grade grade award_year institution_country].freeze
    OTHER_QUALIFICATION_ATTRIBUTES = %i[id qualification_type other_uk_qualification_type non_uk_qualification_type].freeze

    before_validation :sanitize_grade_where_required

    validates :qualification_type, presence: true
    validates :qualification_type, inclusion: { in: ALL_VALID_TYPES, allow_blank: false }
    validates :qualification_type, :subject, :grade, length: { maximum: 255 }

    validates :other_uk_qualification_type, presence: true, if: -> { qualification_type == OTHER_TYPE }, on: :type
    validates :non_uk_qualification_type, presence: true, if: -> { qualification_type == NON_UK_TYPE }, on: :type

    validates :award_year, presence: true, on: :details
    validates :subject, :grade, presence: true, on: :details, if: -> { qualification_type != NON_UK_TYPE && qualification_type != OTHER_TYPE }
    validates :institution_country, presence: true, if: -> { qualification_type == NON_UK_TYPE }, on: :details
    validates :institution_country, inclusion: { in: COUNTRIES }, if: -> { qualification_type == NON_UK_TYPE }, on: :details
    validate :award_year_is_date_and_before_current_year, if: :award_year, on: :details
    validate :grade_format_is_valid, if: :grade, on: :details

    def initialize(state_store = nil, model = nil, attrs = {})
      @state_store = state_store

      persistent_attributes = model.present? ? persistent_attributes(model) : {}

      super(
        persistent_attributes.merge(
          last_saved_state.select { |_, value| value.present? }.deep_merge(attrs),
        ),
      )
    end

    def self.clear_state!(state_store)
      state_store.delete
    end

    def self.build_all_from_application(application_form)
      application_form.application_qualifications.other.order(:created_at).map do |qualification|
        build_from_qualification(qualification)
      end
    end

    def self.build_from_qualification(qualification)
      wizard = CandidateInterface::OtherQualificationWizard.new
      wizard.id = qualification.id
      wizard.copy_attributes(qualification)
      wizard
    end

    def next_step
      if checking_answers.present? && !qualification_type_changed?
        [:check]
      elsif current_step.to_s == 'type'
        [:details]
      else
        [:check]
      end
    end

    def previous_step
      if checking_answers.present?
        [:check]
      elsif current_step.to_s == 'check'
        [:details]
      else
        [:type]
      end
    end

    def save_state!
      @state_store.write(state)
    end

    def clear_state!
      @state_store.delete
    end

    def attributes_for_persistence
      if current_step == :type
        {
          qualification_type: qualification_type,
          other_uk_qualification_type: other_uk_qualification_type,
          non_uk_qualification_type: non_uk_qualification_type,
        }
      else
        {
          qualification_type: qualification_type,
          subject: subject,
          institution_country: institution_country,
          predicted_grade: predicted_grade,
          grade: grade,
          other_uk_qualification_type: other_uk_qualification_type,
          non_uk_qualification_type: non_uk_qualification_type,
          award_year: award_year,
        }
      end
    end

    def initialize_new_qualification(qualifications)
      return if qualifications.blank?

      if previous_qualification_is_of_same_type?(qualifications)
        self.institution_country ||= qualifications[-1].institution_country
        self.award_year ||= qualifications[-1].award_year
      end
      if qualification_type == NON_UK_TYPE
        self.non_uk_qualification_type ||= qualifications[-1].non_uk_qualification_type
      elsif qualification_type == OTHER_TYPE
        self.other_uk_qualification_type ||= qualifications[-1].other_uk_qualification_type
      end
    end

    def copy_attributes(application_qualification)
      assign_attributes(persistent_attributes(application_qualification))
    end

    def persistent_attributes(application_qualification)
      application_qualification.attributes.select { |key, _| PERSISTENT_ATTRIBUTES.include?(key) }
    end

    def previous_qualification_is_of_same_type?(qualifications)
      last_qualification = qualifications[-1]
      qualification_type == last_qualification.qualification_type
    end

    def title
      "#{qualification_type_name} #{subject}"
    end

    def qualification_type_name
      if qualification_type == NON_UK_TYPE
        non_uk_qualification_type
      elsif qualification_type == OTHER_TYPE && other_uk_qualification_type.present?
        other_uk_qualification_type
      else
        qualification_type
      end
    end

    def missing_type_validation_error?
      errors.details[:qualification_type].any? { |e| e[:error] == :blank }
    end

  private

    def qualification_type_changed?
      application_qualification &&
        application_qualification.qualification_type != qualification_type
    end

    def application_qualification
      @application_qualification ||= id.present? && ApplicationQualification.find(id)
    end

    def state
      as_json(only: %w[current_step current_other_qualification_id checking_answers qualification_type other_uk_qualification_type non_uk_qualification_type]).to_json
    end

    def last_saved_state
      state = @state_store&.read

      if state
        JSON.parse(state)
      else
        {}
      end
    end

    def choice_present?
      return true if choice.present?

      errors.add(:choice, 'Do you want to add another qualification?')
      false
    end

    def award_year_is_date_and_before_current_year
      if !valid_year?(award_year)
        errors.add(:award_year, :invalid)
      elsif future_year?(award_year)
        errors.add(:award_year, :in_the_future)
      end
    end

    def grade_format_is_valid
      case qualification_type
      when A_LEVEL_TYPE
        unless grade.in?(A_LEVEL_GRADES)
          errors.add(:grade, :invalid)
        end
      when AS_LEVEL_TYPE
        unless grade.in?(AS_LEVEL_GRADES)
          errors.add(:grade, :invalid)
        end
      end
    end

    def sanitize_grade_where_required
      if qualification_type.in? [A_LEVEL_TYPE, AS_LEVEL_TYPE]
        self.grade = grade.delete(' ').upcase if grade
      end
    end
  end
end
