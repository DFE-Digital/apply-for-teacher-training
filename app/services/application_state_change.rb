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
  workflow do
    state :application_complete do
      event :make_conditional_offer, transitions_to: :conditional_offer
      event :make_unconditional_offer, transitions_to: :unconditional_offer
    end

    state :conditional_offer

    state :unconditional_offer

    state :recruited do
      event :confirm_enrolment, transitions_to: :enrolled
    end

    state :enrolled
  end

  def load_workflow_state
    application_choice.status
  end

  def persist_workflow_state(new_state)
    application_choice.update!(status: new_state)
  end
end
