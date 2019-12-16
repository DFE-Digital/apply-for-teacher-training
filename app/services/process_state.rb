# ProcessState is an *experimental* thing that infers the state from
# the state of application choices. Do not rely on this for business logic.
class ProcessState
  def initialize(application_form)
    @application_form = application_form
  end

  def state
    if application_choices.empty?
      :unsubmitted
    elsif all_states_are?('unsubmitted')
      :unsubmitted
    elsif all_states_are?('awaiting_references')
      :awaiting_references
    elsif all_states_are?('application_complete')
      :waiting_to_be_sent
    elsif any_state_is?('awaiting_provider_decision')
      :awaiting_provider_decisions
    elsif any_state_is?('offer')
      # Offer, but no awaiting means we're waiting on the candidate
      :awaiting_candidate_response
    elsif any_state_is?('enrolled')
      :enrolled
    elsif any_state_is?('recruited')
      :recruited
    elsif any_state_is?('pending_conditions')
      :pending_conditions
    elsif (states.uniq - %w[withdrawn rejected declined conditions_not_met]).empty?
      :ended_without_success
    else
      :unknown_state
    end
  end

private

  attr_reader :application_form
  delegate :application_choices, to: :application_form

  def states
    @states ||= application_choices.map(&:status)
  end

  def all_states_are?(*in_states)
    states.uniq == in_states
  end

  def any_state_is?(state)
    states.include?(state)
  end
end
