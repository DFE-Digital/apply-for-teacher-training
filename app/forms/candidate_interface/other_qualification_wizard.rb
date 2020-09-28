module CandidateInterface
  class OtherQualificationWizard
    include ActiveModel::Model

    attr_accessor :current_step, :current_other_qualification_id, :checking_answers
    attr_accessor :qualification_type, :other_uk_qualification_type, :non_uk_qualification_type
    attr_reader :attrs

    validates :qualification_type, presence: true
    validates :other_uk_qualification_type, presence: true, if: -> { qualification_type == 'Other' && FeatureFlag.active?('international_other_qualifications') }
    validates :non_uk_qualification_type, presence: true, if: -> { qualification_type == 'non_uk' }
    validates :qualification_type, inclusion: { in: ['A level', 'AS level', 'GCSE', 'Other', 'non_uk'], allow_blank: false }

    def initialize(state_store, attrs = {})
      @attrs = attrs
      @state_store = state_store

      super(last_saved_state.deep_merge(attrs))
    end

    def next_step
      if checking_answers.present?
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

  private

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
  end
end
