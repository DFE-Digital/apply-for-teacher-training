module ProviderInterface
  class OfferWizard
    include ActiveModel::Model

    STEPS = { make_offer: %i[select_option conditions check] }.freeze

    attr_accessor :provider_id, :course_id, :study_mode, :location_id,
                  :conditions, :current_step, :current_context

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

      if index
        STEPS[current_context.to_sym][index + 1] if index
      else
        :select_option
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
