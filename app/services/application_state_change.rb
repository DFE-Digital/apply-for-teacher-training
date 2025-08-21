class ApplicationStateChange
  include Workflow

  STATES_NOT_VISIBLE_TO_PROVIDER = %i[unsubmitted cancelled application_not_sent].freeze
  STATES_VISIBLE_TO_PROVIDER = %i[awaiting_provider_decision interviewing offer pending_conditions recruited rejected declined withdrawn conditions_not_met offer_withdrawn offer_deferred inactive].freeze

  INTERVIEWABLE_STATES = %i[awaiting_provider_decision interviewing inactive].freeze
  ACCEPTED_STATES = %i[pending_conditions conditions_not_met recruited offer_deferred].freeze
  OFFERED_STATES = (ACCEPTED_STATES + %i[declined offer offer_withdrawn]).freeze
  POST_OFFERED_STATES = (ACCEPTED_STATES + %i[declined offer_withdrawn]).freeze
  UNSUCCESSFUL_STATES = %i[withdrawn cancelled rejected declined conditions_not_met offer_withdrawn application_not_sent inactive].freeze
  CARRY_OVER_ELIGIBLE_STATES = (UNSUCCESSFUL_STATES - %i[inactive]).freeze
  SUCCESSFUL_STATES = %i[pending_conditions offer offer_deferred recruited].freeze
  DECISION_PENDING_STATUSES = %i[awaiting_provider_decision interviewing].freeze
  DECISION_PENDING_AND_INACTIVE_STATUSES = %i[awaiting_provider_decision interviewing inactive].freeze

  REAPPLY_STATUSES = %i[rejected cancelled withdrawn declined offer_withdrawn].freeze

  TERMINAL_STATES = UNSUCCESSFUL_STATES + %i[recruited].freeze
  IN_PROGRESS_STATES = DECISION_PENDING_STATUSES + ACCEPTED_STATES + %i[offer].freeze - %i[conditions_not_met]

  attr_reader :application_choice

  def initialize(application_choice)
    @application_choice = application_choice
  end

  ApplicationState = Data.define(:id,
                                 :visible_to_provider,
                                 :interviewable,
                                 :offered,
                                 :post_offered,
                                 :offer_accepted,
                                 :unsuccessful,
                                 :carry_over,
                                 :successful,
                                 :pending_provider_decision,
                                 :reapply,
                                 :terminal,
                                 :in_progress) do
    alias_method :visible_to_provider?, :visible_to_provider
    alias_method :interviewable?, :interviewable
    alias_method :offered?, :offered
    alias_method :post_offered?, :post_offered
    alias_method :offer_accepted?, :offer_accepted
    alias_method :unsuccessful?, :unsuccessful
    alias_method :carry_over?, :carry_over
    alias_method :successful?, :successful
    alias_method :pending_provider_decision?, :pending_provider_decision
    alias_method :reapply?, :reapply
    alias_method :terminal?, :terminal
    alias_method :in_progress?, :in_progress

    delegate :to_s, to: :id
  end

  def self.all
    [
      ApplicationState.new(id: :withdrawn, visible_to_provider: true, interviewable: false, offered: false, post_offered: false, offer_accepted: false, unsuccessful: true, carry_over: true, successful: false, pending_provider_decision: false, reapply: true, terminal: true, in_progress: false),
      ApplicationState.new(id: :unsubmitted, visible_to_provider: false, interviewable: false, offered: false, post_offered: false, offer_accepted: false, unsuccessful: false, carry_over: false, successful: false, pending_provider_decision: false, reapply: false, terminal: false, in_progress: false),
      ApplicationState.new(id: :awaiting_provider_decision, visible_to_provider: true, interviewable: true, offered: false, post_offered: false, offer_accepted: false, unsuccessful: false, carry_over: false, successful: false, pending_provider_decision: true, reapply: false, terminal: false, in_progress: true),
      ApplicationState.new(id: :inactive, visible_to_provider: true, interviewable: true, offered: false, post_offered: false, offer_accepted: false, unsuccessful: true, carry_over: false, successful: false, pending_provider_decision: false, reapply: false, terminal: true, in_progress: false),
      ApplicationState.new(id: :interviewing, visible_to_provider: true, interviewable: true, offered: false, post_offered: false, offer_accepted: false, unsuccessful: false, carry_over: false, successful: false, pending_provider_decision: true, reapply: false, terminal: false, in_progress: true),
      ApplicationState.new(id: :rejected, visible_to_provider: true, interviewable: false, offered: false, post_offered: false, offer_accepted: false, unsuccessful: true, carry_over: true, successful: false, pending_provider_decision: false, reapply: true, terminal: true, in_progress: false),
      ApplicationState.new(id: :application_not_sent, visible_to_provider: false, interviewable: false, offered: false, post_offered: false, offer_accepted: false, unsuccessful: true, carry_over: true, successful: false, pending_provider_decision: false, reapply: false, terminal: true, in_progress: false),
      ApplicationState.new(id: :offer, visible_to_provider: true, interviewable: false, offered: true, post_offered: false, offer_accepted: false, unsuccessful: false, carry_over: false, successful: true, pending_provider_decision: false, reapply: false, terminal: false, in_progress: true),
      ApplicationState.new(id: :offer_withdrawn, visible_to_provider: true, interviewable: false, offered: true, post_offered: true, offer_accepted: false, unsuccessful: true, carry_over: true, successful: false, pending_provider_decision: false, reapply: true, terminal: true, in_progress: false),
      ApplicationState.new(id: :declined, visible_to_provider: true, interviewable: false, offered: true, post_offered: true, offer_accepted: false, unsuccessful: true, carry_over: true, successful: false, pending_provider_decision: false, reapply: true, terminal: true, in_progress: false),
      ApplicationState.new(id: :pending_conditions, visible_to_provider: true, interviewable: false, offered: true, post_offered: true, offer_accepted: true, unsuccessful: false, carry_over: false, successful: true, pending_provider_decision: false, reapply: false, terminal: false, in_progress: true),
      ApplicationState.new(id: :conditions_not_met, visible_to_provider: true, interviewable: false, offered: true, post_offered: true, offer_accepted: true, unsuccessful: true, carry_over: true, successful: false, pending_provider_decision: false, reapply: false, terminal: true, in_progress: false),
      ApplicationState.new(id: :recruited, visible_to_provider: true, interviewable: false, offered: true, post_offered: true, offer_accepted: true, unsuccessful: false, carry_over: false, successful: true, pending_provider_decision: false, reapply: false, terminal: true, in_progress: true),
      ApplicationState.new(id: :cancelled, visible_to_provider: false, interviewable: false, offered: false, post_offered: false, offer_accepted: false, unsuccessful: true, carry_over: true, successful: false, pending_provider_decision: false, reapply: true, terminal: true, in_progress: false),
      ApplicationState.new(id: :offer_deferred, visible_to_provider: true, interviewable: false, offered: true, post_offered: true, offer_accepted: true, unsuccessful: false, carry_over: false, successful: true, pending_provider_decision: false, reapply: false, terminal: false, in_progress: true),
    ]
  end

  def self.where(**args)
    all.select do |state|
      args.all? do |attr, values|
        Array.wrap(values).any? do |value|
          state.public_send(attr) == value
        end
      end
    end
  end

  def self.find(state_id)
    all.find { |state| state.id == state_id }
  end

  def self.not_visible_to_provider
    where(visible_to_provider: false)
  end

  def self.visible_to_provider
    where(visible_to_provider: true)
  end

  def self.interviewable
    where(interviewable: true)
  end

  def self.offered
    where(offered: true)
  end

  def self.post_offered
    where(post_offered: true)
  end

  def self.offer_accepted
    where(offer_accepted: true)
  end

  def self.unsuccessful
    where(unsuccessful: true)
  end

  def self.carry_over
    where(carry_over: true)
  end

  def self.successful
    where(successful: true)
  end

  def self.pending_provider_decision
    where(pending_provider_decision: true)
  end

  def self.pending_provider_decision_or_inactive
    pending_provider_decision | where(id: :inactive)
  end

  def self.reapply
    where(reapply: true)
  end

  def self.terminal
    where(terminal: true)
  end

  def self.in_progress
    where(in_progress: true)
  end

  # When updating states, do not forget to run:
  #
  #   bundle exec rake generate_state_diagram
  #
  workflow do
    state :withdrawn

    state :unsubmitted do
      event :send_to_provider, transitions_to: :awaiting_provider_decision
      event :reject_at_end_of_cycle, transitions_to: :application_not_sent
    end

    state :awaiting_provider_decision do
      event :make_offer, transitions_to: :offer
      event :reject, transitions_to: :rejected
      event :reject_by_default, transitions_to: :rejected
      event :withdraw, transitions_to: :withdrawn
      event :interview, transitions_to: :interviewing
      event :inactivate, transitions_to: :inactive
    end

    state :inactive do
      event :make_offer, transitions_to: :offer
      event :reject, transitions_to: :rejected
      event :reject_by_default, transitions_to: :rejected
      event :withdraw, transitions_to: :withdrawn
      event :interview, transitions_to: :interviewing
    end

    state :interviewing do
      event :make_offer, transitions_to: :offer
      event :reject, transitions_to: :rejected
      event :reject_by_default, transitions_to: :rejected
      event :withdraw, transitions_to: :withdrawn
      event :interview, transitions_to: :interviewing
      event :cancel_interview, transitions_to: :awaiting_provider_decision
    end

    state :rejected do
      event :make_offer, transitions_to: :offer
    end

    state :application_not_sent

    state :offer do
      event :make_offer, transitions_to: :offer
      event :withdraw_offer, transitions_to: :offer_withdrawn
      event :accept, transitions_to: :pending_conditions
      event :accept_unconditional_offer, transitions_to: :recruited
      event :decline, transitions_to: :declined
      event :decline_by_default, transitions_to: :declined
    end

    state :offer_withdrawn do
      event :make_offer, transitions_to: :offer
    end

    state :declined

    state :pending_conditions do
      event :confirm_conditions_met, transitions_to: :recruited
      event :recruit_with_pending_conditions, transitions_to: :recruited
      event :conditions_not_met, transitions_to: :conditions_not_met
      event :withdraw, transitions_to: :withdrawn
      event :defer_offer, transitions_to: :offer_deferred
    end

    state :conditions_not_met

    state :recruited do
      event :withdraw, transitions_to: :withdrawn
      event :defer_offer, transitions_to: :offer_deferred
      event :confirm_conditions_met, transitions_to: :recruited
    end

    # This state is no longer used. Before the "uncoupled references" feature,
    # candidates could cancel their application if they had submitted it and
    # it hadn't been sent to the provider yet.
    state :cancelled

    state :offer_deferred do
      event :reinstate_conditions_met, transitions_to: :recruited
      event :reinstate_pending_conditions, transitions_to: :pending_conditions
      event :withdraw, transitions_to: :withdrawn
    end
  end

  def load_workflow_state
    application_choice.status
  end

  def persist_workflow_state(new_state)
    previous_application_form_status = ApplicationFormStateInferrer.new(application_choice.application_form).state
    application_choice.update!(status: new_state)
    current_application_form_status = ApplicationFormStateInferrer.new(application_choice.application_form.reload).state
    update_candidate_api_updated_at_if_application_forms_state_has_changed(previous_application_form_status, current_application_form_status)
  end

  # State Categories
  def self.valid_states
    workflow_spec.states.keys
  end

  def self.reapply_states
    REAPPLY_STATUSES
  end

  def self.non_reapply_states
    valid_states - REAPPLY_STATUSES
  end

  def self.states_visible_to_provider
    STATES_VISIBLE_TO_PROVIDER
  end

  def self.states_visible_to_provider_without_deferred
    states_visible_to_provider - [:offer_deferred]
  end

  def self.states_visible_to_provider_without_inactive
    states_visible_to_provider - [:inactive]
  end

  def self.i18n_namespace
    ''
  end

  def self.state_count(state_name)
    ApplicationChoice.where(status: state_name).count
  end

private

  def update_candidate_api_updated_at_if_application_forms_state_has_changed(previous_application_form_status, current_application_form_status)
    if previous_application_form_status != current_application_form_status
      application_choice.candidate.update!(candidate_api_updated_at: Time.zone.now)
    end
  end
end
