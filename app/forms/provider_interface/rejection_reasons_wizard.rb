module ProviderInterface
  class RejectionReasonsWizard
    extend DynamicRejectionReasons
    include Wizard

    initialize_dynamic_rejection_reasons

    def initialize_extra(_attrs)
      @checking_answers = true if current_step == 'check'
    end

    def to_model
      RejectionReasons.new(last_saved_state.except('current_step', 'checking_answers'))
    end

    def next_step
      'check'
    end
  end
end
