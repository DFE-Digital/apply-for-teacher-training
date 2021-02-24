module ProviderInterface
  class OfferWizard
    include ActiveModel::Model
    STANDARD_CONDITIONS = ['Fitness to train to teach check',
                           'Disclosure and Barring Service (DBS) check'].freeze

    STEPS = {
      default: [:select_option ],
      new_offer: [:select_option,
                  :conditions,
                  :check],
      make_changed_offer: [:select_option,
                           :select_provider,
                           :select_course,
                           :select_study_mode,
                           :select_location,
                           :conditions,
                           :check]
    }.freeze

    attr_accessor :provider_id, :provider, :course_id, :course_option_id, :study_mode, :location_id, :conditions, :current_step, :current_context

    validate :validate_conditions_max_length, on: :conditions
    validate :validate_further_conditions, on: :conditions

    def initialize(state_store, attrs = {})
      @state_store = state_store

      super(last_saved_state.deep_merge(attrs))
    end

    def save_state!
      @state_store.write(state)
    end

    def clear_state!
      @state_store.delete
    end

    def valid_for_current_step?
      valid?(current_step.to_sym)
    end

    def next_step
      index = STEPS[current_context.to_sym].index(current_step.to_sym)
      puts index
      if index
        STEPS[current_context.to_sym][index + 1]
      end
    end

    private

    def last_saved_state
      saved_state = @state_store.read
      saved_state ? JSON.parse(saved_state) : {}
    end

    def state
      as_json(except: %w[state_store errors validation_context]).to_json
    end
  end
end
