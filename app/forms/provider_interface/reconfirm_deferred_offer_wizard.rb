module ProviderInterface
  class ReconfirmDeferredOfferWizard
    include ActiveModel::Model

    STEPS = %w[start conditions update_conditions check commit].freeze

    attr_accessor :application_choice_id, :current_step
    attr_accessor :course_option_in_new_cycle
    attr_accessor :conditions_status, :course_option_id
    attr_writer :state_store

    validates :application_choice_id, :current_step, presence: true
    validate :validate_step, :validate_form, :is_course_option_still_available

    validates :conditions_status, presence: true, if: proc { |f|
      %w[update_conditions check commit].include? f.current_step
    }

    validates :course_option_id, presence: true, if: proc { |f|
      %w[commit].include? f.current_step
    }

    class DeferredOfferForm
      include ActiveModel::Model
      attr_accessor :id
      attr_reader :application_choice

      validates :id, presence: true
      validate :validate_application_choice

      def validate_application_choice
        @application_choice = ApplicationChoice.find_by(id: id)

        if application_choice
          errors.add(:id, 'is not a deferred offer') \
            unless application_choice.status == 'offer_deferred'
          errors.add(:id, 'is not from the previous recruitment cycle') \
            unless application_choice.recruitment_cycle == RecruitmentCycle.previous_year
        else
          errors.add(:id, 'does not exist')
        end
      end
    end

    def initialize(state_store, attrs = {})
      @state_store = state_store

      super(last_saved_state.deep_merge(attrs))
    end

    def is_course_option_still_available
      @course_option_in_new_cycle = current_form.application_choice&.offered_option&.in_next_cycle

      if current_step != 'start'
        errors.add(:course_option_in_new_cycle, "No matching course option in #{RecruitmentCycle.current_year}") unless @course_option_in_new_cycle
      end
    end

    def conditions_met?
      conditions_status.present? && conditions_status == 'met'
    end

    def course_option
      CourseOption.find(course_option_id) if course_option_id.present?
    end

    def modified_application_choice
      return unless current_form.application_choice

      clone = current_form.application_choice.dup

      clone.status = if conditions_status.present?
                       conditions_met? ? 'recruited' : 'pending_conditions'
                     else
                       clone.status_before_deferral
                     end
      clone
    end

    def next_step
      if current_step == 'start'
        [:conditions]
      elsif current_step == 'conditions'
        [:update_conditions]
      elsif current_step == 'update_conditions'
        [:check]
      elsif current_step == 'check'
        [:commit]
      elsif current_step == 'commit'
        nil
      else
        [:start]
      end
    end

    def previous_step
      if current_step == 'start'
        nil
      elsif current_step == 'conditions'
        [:start]
      elsif current_step == 'update_conditions'
        [:conditions]
      elsif current_step == 'check'
        [:conditions]
      elsif current_step == 'commit'
        [:check]
      end
    end

    def save_state!
      @state_store.write(state)
    end

    def clear_state!
      @state_store.delete
    end

    def current_form
      @_current_form ||= DeferredOfferForm.new(
        deferred_offer_data.merge(id: application_choice_id),
      )
    end

  private

    def state
      as_json(except: %w[state_store errors validation_context _current_form current_step]).to_json
    end

    def last_saved_state
      state = @state_store.read

      if state
        JSON.parse(state)
      else
        {}
      end
    end

    def deferred_offer_data
      @_deferred_offer_data || {}
    end

    def validate_step
      errors.add(:current_step, 'is not a valid step') unless STEPS.include?(current_step)
    end

    def validate_form
      return if current_form.valid?

      current_form.errors.map do |key, message|
        key = :application_choice_id if key == :id
        errors.add(key, message)
      end
    end
  end
end
