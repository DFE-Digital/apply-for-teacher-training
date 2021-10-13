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
      event :sign_in, transitions_to: :unsubmitted_not_started_form
    end

    state :unsubmitted_not_started_form do
      event :edit_form, transitions_to: :unsubmitted_in_progress
    end

    state :unsubmitted_in_progress do
      event :submit, transitions_to: :awaiting_provider_decisions
    end

    state :awaiting_provider_decisions do
      event :at_least_one_offer, transitions_to: :awaiting_candidate_response
      event :no_offers, transitions_to: :ended_without_success
      event :all_rejected, transitions_to: :ended_without_success
      event :all_withdrawn, transitions_to: :ended_without_success
      event :interview, transitions_to: :interviewing
    end

    state :interviewing do
      event :at_least_one_offer, transitions_to: :awaiting_candidate_response
      event :no_offers, transitions_to: :ended_without_success
      event :all_rejected, transitions_to: :ended_without_success
      event :all_withdrawn, transitions_to: :ended_without_success
    end

    state :awaiting_candidate_response do
      event :offer_accepted, transitions_to: :pending_conditions
      event :all_offers_declined, transitions_to: :ended_without_success
    end

    state :ended_without_success do
      event :start_apply_again, transitions_to: :unsubmitted_in_progress
    end

    state :pending_conditions do
      event :conditions_met, transitions_to: :recruited
      event :conditions_not_met, transitions_to: :ended_without_success
      event :defer_offer, transitions_to: :offer_deferred
    end

    state :recruited do
      event :defer_offer, transitions_to: :offer_deferred
    end

    state :offer_deferred do
      event :reinstate_conditions_met, transitions_to: :recruited
      event :reinstate_pending_conditions, transitions_to: :pending_conditions
      event :withdraw, transitions_to: :ended_without_success
    end
  end

  def state
    if application_form.nil?
      :never_signed_in
    elsif application_choices.empty? || all_states_are?('unsubmitted')
      unchanged?(application_form) ? :unsubmitted_not_started_form : :unsubmitted_in_progress
    elsif any_state_is?('awaiting_provider_decision') || any_state_is?('interviewing')
      :awaiting_provider_decisions
    elsif any_state_is?('offer')
      # Offer, but no awaiting means we're waiting on the candidate
      :awaiting_candidate_response
    elsif any_state_is?('recruited')
      :recruited
    elsif any_state_is?('pending_conditions')
      :pending_conditions
    elsif any_state_is?('offer_deferred')
      :offer_deferred
    elsif (states.uniq.map(&:to_sym) - ApplicationStateChange::UNSUCCESSFUL_END_STATES).empty?
      :ended_without_success
    else
      :unknown_state
    end
  end

  def self.i18n_namespace
    'candidate_flow_'
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

  def unchanged?(application_form)
    application_form.created_at.to_i == application_form.updated_at.to_i
  end
end
