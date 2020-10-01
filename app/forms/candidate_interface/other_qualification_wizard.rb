module CandidateInterface
  class OtherQualificationWizard
    include ActiveModel::Model
    include ValidationUtils

    attr_accessor :current_step, :current_other_qualification_id, :checking_answers
    attr_accessor :qualification_type, :other_uk_qualification_type, :non_uk_qualification_type
    attr_accessor :id, :subject, :predicted_grade, :grade, :award_year, :choice, :institution_country
    attr_reader :attrs

    PERSISTENT_ATTRIBUTES = %w[qualification_type other_uk_qualification_type non_uk_qualification_type subject predicted_grade grade award_year institution_country].freeze

    validates :qualification_type, presence: true
    validates :qualification_type, inclusion: { in: ['A level', 'AS level', 'GCSE', 'Other', 'non_uk'], allow_blank: false }
    validates :qualification_type, :subject, :grade, length: { maximum: 255 }

    validates :other_uk_qualification_type, presence: true, if: -> { qualification_type == 'Other' && FeatureFlag.active?('international_other_qualifications') }, on: :type
    validates :non_uk_qualification_type, presence: true, if: -> { qualification_type == 'non_uk' }, on: :type

    validates :award_year, presence: true, on: :details
    validates :subject, :grade, presence: true, unless: -> { qualification_type == 'non_uk' || qualification_type == 'Other' }, on: :details
    validates :institution_country, presence: true, if: -> { qualification_type == 'non_uk' }, on: :details
    validates :institution_country, inclusion: { in: COUNTRIES }, if: -> { qualification_type == 'non_uk' }, on: :details
    validate :award_year_is_date_and_before_current_year, if: :award_year, on: :details

    def initialize(state_store, attrs = {})
      @attrs = attrs
      @state_store = state_store

      super(last_saved_state.deep_merge(attrs))
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

    OTHER_QUALIFICATION_ATTRIBUTES = %i[id qualification_type other_uk_qualification_type non_uk_qualification_type].freeze

    def qualification_type_form
      @qualification_type_form ||= OtherQualificationTypeForm.new(attrs.select { |key, _| OTHER_QUALIFICATION_ATTRIBUTES.include?(key) })
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
      self.non_uk_qualification_type ||= qualifications[-1].non_uk_qualification_type
      self.other_uk_qualification_type ||= qualifications[-1].other_uk_qualification_type
    end

    def copy_attributes(application_qualification)
      assign_attributes(application_qualification.attributes.select { |key, _| PERSISTENT_ATTRIBUTES.include?(key) })
    end

    def previous_qualification_is_of_same_type?(qualifications)
      last_qualification = qualifications[-1]
      qualification_type == last_qualification.qualification_type
    end

    def qualication_type_name
      if qualification_type == 'non_uk'
        non_uk_qualification_type
      elsif qualification_type == 'Other' && FeatureFlag.active?('international_other_qualifications')
        other_uk_qualification_type
      else
        qualification_type
      end
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
      state = @state_store.read

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
      year_limit = Time.zone.today.year.to_i + 1

      if !valid_year?(award_year)
        errors.add(:award_year, :invalid)
      elsif award_year.to_i >= year_limit
        errors.add(:award_year, :in_the_future, date: year_limit)
      end
    end
  end
end
