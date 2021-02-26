module ProviderInterface
  class CancelInterviewWizard
    include ActiveModel::Model

    attr_accessor :cancellation_reason

    validates :cancellation_reason, presence: true, word_count: { maximum: 2000 }

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
