module SupportInterface
  class CandidateJourneyTracker
    def initialize(application_choice)
      @application_choice = application_choice
    end

    def form_not_started
      @application_choice.application_form.created_at
    end

    def form_started_and_not_submitted
      [
        @application_choice.application_form.audits.where(action: :update).minimum(:created_at),
        @application_choice.created_at,
      ].compact.min
    end

    def submitted_and_awaiting_references
      @application_choice.application_form.submitted_at
    end

    def reference_1_received
      received_reference_times[0]
    end

    def reference_2_received
      received_reference_times[1]
    end

    def reference_reminder_email_sent
      earliest_chaser_sent(:reference_request)
    end

    def new_reference_request_email_sent
      earliest_chaser_sent(:reference_replacement)
    end

  private

    def received_references
      @received_references ||= @application_choice
        .application_form
        .application_references
        .select(&:feedback_provided?)
    end

    def received_reference_times
      @received_reference_times ||=
        received_references.map { |reference| earliest_update_audit_for(reference, feedback_status: 'feedback_provided') }.compact.sort
    end

    def earliest_update_audit_for(model, attributes)
      audits = model.audits.select do |audit|
        audit.action == 'update' &&
          attributes.all? do |attribute, value|
            change = audit.audited_changes[attribute.to_s]
            change && change[1] == value
          end
      end

      audits.map(&:created_at).min
    end

    def earliest_chaser_sent(chaser_type)
      chasers = @application_choice.application_form.application_references.map(&:chasers_sent).flatten
      chasers.select { |chaser| chaser.chaser_type == chaser_type.to_s }.map(&:created_at).min
    end

    # def new_reference_request_email_sent: nil, # - emails?
    # def new_reference_added: nil, # - ?
    # def references_complete: nil, # - from audit trail when `ApplicationForm#references_completed` gets set to true? (can happen more than once)
    # def waiting_to_be_sent_to_provider: nil, # - not sure what this one means
    # def application_sent_to_provider: nil, # - `ApplicationChoice#sent_to_provider_at`
    # def awaiting_decision: nil, # QUESTION - not sure what this means (isn't it the same as `sent_to_provider_at`?)
    # def rbd_date: nil, # - `ApplicationChoice#sent_to_provider_at`
    # def rbd_reminder_sent: nil, # - Is this the `chase_provider_decision` email? `ChaserSent#provider_decision_request` ?
    # def application_rbd: nil, # - Combination of `ApplicationChoice#rejected_at` and `rejected_by_default`
    # def provider_decision: nil, # (Reject/Offer) - `ApplicationChoice#rejected_at` or `ApplicationChoice#offered_at`
    # def offer_made: nil, # awaiting decision from candidate - `ApplicationChoice#offered_at`
    # def email_sent_to_candidate: nil, # - the offer email? also the reject email?
    # def dbd_date: nil, # - `ApplicationChoice#decline_by_default_at`
    # def dbd_reminder_email: nil, # - `ChaserSent#chaser_type`
    # def candidate_decision: nil, # (accept/decline) - `ApplicationChoice#accepted_at` or `ApplicationChoice#declined_at`
    # def offer_declined: nil, # - `ApplicationChoice#declined_at`
    # def offer_accepted: nil, # - `ApplicationChoice#accepted_at`
    # def email_sent_to_candidate_2: nil, # - the offer accepted email? QUESTION
    # def pending_conditions: nil, # - from audit trail
    # def conditions_outcome: nil, # - from audit trail
    # def conditions_met: nil, # - from audit trail
    # def conditions_not_met: nil, # - from audit trail
    # def enrolled: nil, # - from audit trail
    # def ended_without_success: nil, # - audit trail?
    # def send_rejection_email: nil, # - emails?
  end
end
