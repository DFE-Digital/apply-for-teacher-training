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
      event :reject_application, transitions_to: :rejected
    end

    state :conditional_offer do
      event :confirm_conditions_met, transitions_to: :recruited
    end

    state :unconditional_offer

    state :recruited do
      event :confirm_enrolment, transitions_to: :enrolled
    end

    state :enrolled

    state :rejected
  end

  def load_workflow_state
    application_choice.status
  end

  def persist_workflow_state(new_state)
    application_choice.update!(status: new_state)
  end
end
