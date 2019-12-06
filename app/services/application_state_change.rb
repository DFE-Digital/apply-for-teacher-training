class ApplicationStateChange
  include Workflow

  attr_reader :application_choice

  def initialize(application_choice)
    @application_choice = application_choice
  end

  # When updating states, don't forget to run:
  #
  #   bundle exec rake generate_state_diagram
  #
  # rubocop:disable Metrics/BlockLength
  workflow do
    state :unsubmitted do
      event :submit, transitions_to: :awaiting_references
    end

    state :awaiting_references do
      event :references_complete, transitions_to: :application_complete
      event :withdraw, transitions_to: :withdrawn
    end

    state :application_complete do
      event :send_to_provider, transitions_to: :awaiting_provider_decision
      event :withdraw, transitions_to: :withdrawn
    end

    state :awaiting_provider_decision do
      event :make_offer, transitions_to: :offer
      event :reject_application, transitions_to: :rejected
      event :withdraw, transitions_to: :withdrawn
    end

    state :offer do
      event :make_offer, transitions_to: :offer
      event :accept, transitions_to: :pending_conditions
      event :decline, transitions_to: :declined
    end

    state :pending_conditions do
      event :confirm_conditions_met, transitions_to: :recruited
      event :withdraw, transitions_to: :withdrawn
    end

    state :recruited do
      event :confirm_enrolment, transitions_to: :enrolled
      event :withdraw, transitions_to: :withdrawn
    end

    state :enrolled

    state :rejected

    state :declined

    state :withdrawn
  end
  # rubocop:enable Metrics/BlockLength

  def load_workflow_state
    application_choice.status
  end

  def persist_workflow_state(new_state)
    application_choice.update!(status: new_state)
  end

  def self.valid_states
    workflow_spec.states.keys
  end
end
