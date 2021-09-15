module ProviderInterface
  class CancelInterviewWizard
    include ActiveModel::Model

    attr_accessor :cancellation_reason, :path_history, :wizard_path_history, :current_step, :action, :referer

    validates :cancellation_reason, presence: true, word_count: { maximum: 2000 }

    def initialize(state_store, attrs = {})
      @state_store = state_store

      super(last_saved_state.deep_merge(attrs))
      @path_history ||= [:referer]
      update_path_history(attrs)
    end

    def save_state!
      @state_store.write(state)
    end

    def clear_state!
      @state_store.delete
    end

    def previous_step
      wizard_path_history.previous_step
    rescue WizardPathHistory::NoSuchStepError
      :referer
    end

  private

    def update_path_history(attrs)
      @wizard_path_history = WizardPathHistory.new(@path_history,
                                                   step: attrs[:current_step].presence,
                                                   action: attrs[:action].presence)
      @wizard_path_history.update
      @path_history = @wizard_path_history.path_history
    end

    def last_saved_state
      saved_state = @state_store.read
      saved_state ? JSON.parse(saved_state) : {}
    end

    def state
      as_json(except: %w[state_store errors validation_context]).to_json
    end
  end
end
