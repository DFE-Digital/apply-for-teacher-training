# Manage and arrange the states and Workflow for teh ApplicationChoice#status state machine property
#
# Big Question: Do the states categories need to have meaning relative to one another?
#
# 1. What is decision pending, where is it used and why does it not include inactive
#  a) app/mailers/candidate_mailer#changed_offer
#     We send an email to candidates when an offer they received has changed. We list the other decision pending in the email and ask if they want to accept the offer or hear back about their decision pending offers. We do not list the inactive ones in this email.
#  b)
#
#
#  With inactive
#  1) When accepting an offer we withdraw all decision pending, including inactive
#
#
#
#
# Categories:
#   The full list of possible states of an ApplicationChoice can be arranged into higher categories which communicate the meaning of the states, allow performing operation on records.
#   1. Unsubmitted - The form has been created and perhaps completed by the candidate but it has not been submitted
#   2. Submitted
#     a. In Progress - The application is submitted but it is in the pipeline for consideration.
#       i) Awaiting Provider Decision
#      ii) Interviewing
#     iii) Offer Conditions Not Met
#
#     b. Post Offer -
#
class ApplicationStateChange
  include Workflow
  using InverseHash

  # Application Progression States
  # Unsubmitted -> Decision Pending -> Offered -> Success/Unsuccess
  DECISION_PENDING_STATUSES = %i[awaiting_provider_decision interviewing].freeze
  DECISION_PENDING_AND_INACTIVE_STATUSES = %i[awaiting_provider_decision interviewing inactive].freeze
  INTERVIEWABLE_STATES = %i[awaiting_provider_decision interviewing inactive].freeze

  ACCEPTED_STATES = %i[pending_conditions conditions_not_met recruited offer_deferred].freeze
  OFFERED_STATES = (ACCEPTED_STATES + %i[declined offer offer_withdrawn]).freeze

  EXCLUSIVE_OFFER_STATES = %i[pending_conditions recruited offer_deferred].freeze

  POST_OFFERED_STATES = (ACCEPTED_STATES + %i[declined offer_withdrawn]).freeze

  UNSUCCESSFUL_STATES = %i[withdrawn cancelled rejected declined conditions_not_met offer_withdrawn application_not_sent inactive].freeze
  SUCCESSFUL_STATES = %i[pending_conditions offer offer_deferred recruited].freeze

  TERMINAL_STATES = UNSUCCESSFUL_STATES + %i[recruited].freeze

  # Utility states
  STATES_NOT_VISIBLE_TO_PROVIDER = %i[unsubmitted cancelled application_not_sent].freeze
  STATES_VISIBLE_TO_PROVIDER = %i[awaiting_provider_decision interviewing offer pending_conditions recruited rejected declined withdrawn conditions_not_met offer_withdrawn offer_deferred inactive].freeze

  REAPPLY_STATUSES = %i[rejected cancelled withdrawn declined offer_withdrawn].freeze
  # Used to determine if a candidate can add another application to their form
  IN_PROGRESS_STATES = DECISION_PENDING_STATUSES + ACCEPTED_STATES + %i[offer].freeze

  # rubocop:disable Layout/HashAlignment
  STATES_BY_CATEGORY = {
    # Why is recruiteed in "in_progress"
    decision_pending:              %i[awaiting_provider_decision interviewing],
    decision_pending_and_inactive: %i[awaiting_provider_decision inactive interviewing],

    interviewable:                 %i[awaiting_provider_decision interviewing],
    offered:                       %i[conditions_not_met declined offer offer_deferred offer_withdrawn pending_conditions recruited],

    post_offered:                  %i[conditions_not_met declined declined offer_deferred offer_withdrawn offer_withdrawn pending_conditions recruited],
    accepted:                      %i[conditions_not_met offer_deferred pending_conditions recruited],
    exclusive_offer:               %i[offer_deferred pending_conditions recruited],
    unsuccessful:                  %i[withdrawn cancelled rejected declined conditions_not_met offer_withdrawn application_not_sent inactive],
    successful:                    %i[offer offer_deferred pending_conditions recruited],
    terminal:                      %i[application_not_sent cancelled conditions_not_met declined inactive offer_withdrawn recruited rejected withdrawn],

    in_progress:                   %i[awaiting_provider_decision interviewing conditions_not_met offer_deferred pending_conditions recruited offer],
    reapply:                       %i[cancelled declined offer_withdrawn rejected withdrawn],
    not_visible_to_provider:       %i[unsubmitted cancelled application_not_sent],
    visible_to_provider:           %i[awaiting_provider_decision conditions_not_met declined inactive interviewing offer offer_deferred offer_withdrawn pending_conditions recruited rejected withdrawn],
  }.freeze
  # rubocop:enable Layout/HashAlignment

  CATEGORIES_BY_STATE = STATES_BY_CATEGORY.inverse

  attr_reader :application_choice

  def initialize(application_choice)
    @application_choice = application_choice
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

  def self.categories_by_state
    CATEGORIES_BY_STATE
  end

  def self.states_by_category
    STATES_BY_CATEGORY
  end

  states_by_category.each do |k, v|
    define_singleton_method(k) do
      v
    end
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

  def self.non_reapply_states
    valid_states - reapply
  end

  def self.states_visible_to_provider_without_deferred
    visible_to_provider - [:offer_deferred]
  end

  def self.states_visible_to_provider_without_inactive
    visible_to_provider - [:inactive]
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
