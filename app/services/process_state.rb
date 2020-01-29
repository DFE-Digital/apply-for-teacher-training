# ProcessState is an *experimental* thing that infers the state from
# the state of application choices. Do not rely on this for business logic.
class ProcessState
  include Workflow

  def initialize(application_form)
    @application_form = application_form
  end

  workflow do
    state :not_signed_up do
      event :sign_up, transitions_to: :never_signed_in
    end

    state :never_signed_in do
      event :sign_in, transitions_to: :unsubmitted
    end

    state :unsubmitted do
      event :submit, transitions_to: :awaiting_references
    end

    state :awaiting_references do
      event :references_complete, transitions_to: :waiting_to_be_sent
      event :all_withdrawn, transitions_to: :ended_without_success
    end

    state :waiting_to_be_sent do
      event :send_to_provider, transitions_to: :awaiting_provider_decisions
      event :all_withdrawn, transitions_to: :ended_without_success
    end

    state :awaiting_provider_decisions do
      event :at_least_one_offer, transitions_to: :awaiting_candidate_response
      event :no_offers, transitions_to: :ended_without_success
      event :all_rejected, transitions_to: :ended_without_success
      event :all_withdrawn, transitions_to: :ended_without_success
    end

    state :awaiting_candidate_response do
      event :offer_accepted, transitions_to: :pending_conditions
      event :all_offers_declined, transitions_to: :ended_without_success
    end

    state :ended_without_success

    state :pending_conditions do
      event :conditions_met, transitions_to: :recruited
      event :conditions_not_met, transitions_to: :ended_without_success
    end

    state :recruited do
      event :enrol, transitions_to: :enrolled
    end

    state :enrolled
  end

  def state
    if application_form.nil?
      :never_signed_in
    elsif application_choices.empty?
      :unsubmitted
    elsif all_states_are?('unsubmitted')
      :unsubmitted
    elsif any_state_is?('awaiting_references')
      :awaiting_references
    elsif any_state_is?('application_complete')
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
