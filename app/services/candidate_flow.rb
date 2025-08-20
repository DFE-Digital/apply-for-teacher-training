class CandidateFlow
  include Workflow

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

    state :inactive do
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

  def self.i18n_namespace
    'candidate_flow_'
  end
end
