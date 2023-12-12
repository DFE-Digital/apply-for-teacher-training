class ApplicationFormStateInferrer
  POST_SUBMISSION_STATES = %i[
    awaiting_provider_decisions
    awaiting_candidate_response
    recruited
    pending_conditions
    offer_deferred
    ended_without_success
  ].freeze

  def initialize(application_form)
    @application_form = application_form
  end

  def state
    if application_form.nil?
      :never_signed_in
    elsif application_choices.empty? || all_states_are?('unsubmitted') || all_states_are?('application_not_sent')
      as_new?(application_form) ? :unsubmitted_not_started_form : :unsubmitted_in_progress
    elsif any_state_is?('awaiting_provider_decision') || any_state_is?('interviewing') || any_state_is?('inactive')
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
    elsif (states.uniq.map(&:to_sym) - ApplicationStateChange::UNSUCCESSFUL_STATES).empty?
      :ended_without_success
    elsif any_state_is?('unsubmitted')
      :unsubmitted_in_progress
    else
      :unknown_state
    end
  end

  def post_submission?
    POST_SUBMISSION_STATES.include?(state)
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

  def as_new?(application_form)
    application_form.created_at.to_i == application_form.updated_at.to_i
  end
end
