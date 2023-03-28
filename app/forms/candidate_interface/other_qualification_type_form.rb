module CandidateInterface
  class OtherQualificationTypeForm
    A_LEVEL_TYPE = 'A level'.freeze
    AS_LEVEL_TYPE = 'AS level'.freeze
    GCSE_TYPE = 'GCSE'.freeze
    OTHER_TYPE = 'Other'.freeze
    NON_UK_TYPE = 'non_uk'.freeze
    ALL_VALID_TYPES = [A_LEVEL_TYPE, AS_LEVEL_TYPE, GCSE_TYPE, OTHER_TYPE, NON_UK_TYPE].freeze

    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_reader :next_step
    attr_accessor :editing, :id, :current_step,
                  :subject, :institution_country, :choice, :award_year, :predicted_grade,
                  :grade, :qualification_type, :other_uk_qualification_type, :non_uk_qualification_type

    validates :qualification_type, presence: true, length: { maximum: ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH }
    validates :qualification_type, inclusion: { in: ALL_VALID_TYPES + %w[no_other_qualifications], allow_blank: false }
    validates :other_uk_qualification_type, presence: true, if: -> { qualification_type == OTHER_TYPE }
    validates :other_uk_qualification_type, length: { maximum: 100 }
    validates :non_uk_qualification_type, presence: true, if: -> { qualification_type == NON_UK_TYPE }
    validates :non_uk_qualification_type, length: { maximum: ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH }

    def initialize(current_application = nil, intermediate_data_service = nil, options = nil)
      @current_application = current_application
      @intermediate_data_service = intermediate_data_service
      options = @intermediate_data_service.read.merge(options.select { |_, value| value.present? }) if @intermediate_data_service

      if options && [A_LEVEL_TYPE, AS_LEVEL_TYPE, GCSE_TYPE].include?(options['qualification_type'])
        options['non_uk_qualification_type'] = nil
        options['institution_country'] = nil
      end

      super(options)
    end

    def save_intermediate
      valid? && save_intermediate!
    end

    def save_no_other_qualifications
      return false unless valid?

      @current_application.update!(no_other_qualifications: true)
    end

    def no_other_qualification?
      qualification_type == 'no_other_qualifications'
    end

    def save_intermediate!
      sanitize_types
      @intermediate_data_service.write(intermediate_state)
      @next_step = editing && !qualification_type_changed? ? :check : :details
      true
    end

    def save!
      sanitize_types
      application_qualification = @current_application.application_qualifications.other.find(id)
      application_qualification.update!(attributes_for_persistence)
    end

    PERSISTENT_ATTRIBUTES = %w[id current_step editing qualification_type other_uk_qualification_type non_uk_qualification_type institution_country].freeze

  private

    def sanitize_types
      self.other_uk_qualification_type = nil unless qualification_type == OTHER_TYPE
      self.non_uk_qualification_type = nil unless qualification_type == NON_UK_TYPE
    end

    def attributes_for_persistence
      {
        qualification_type:,
        other_uk_qualification_type:,
        non_uk_qualification_type:,
      }
    end

    def intermediate_state
      as_json(only: PERSISTENT_ATTRIBUTES)
    end

    def qualification_type_changed?
      id && ApplicationQualification.find(id)&.qualification_type != qualification_type
    end
  end
end
