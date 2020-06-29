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

    def new_reference_added
      references_created_at = all_references.map(&:created_at).sort
      references_created_at.size >= 2 ? references_created_at[2] : nil
    end

    def references_completed
      earliest_update_audit_for(@application_choice.application_form, references_completed: true)
    end

  private

    def all_references
      @all_references ||= @application_choice
        .application_form
        .application_references
    end

    def received_references
      @received_references ||= all_references.select(&:feedback_provided?)
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

    # - [x] `form_not_started`
    # - [x] `form_started_and_not_submitted`
    # - [x] `submitted_and_awaiting_references`
    # - [x] `reference_1_received`
    # - [x] `reference_2_received`
    # - [x] `reference_reminder_email_sent`
    # - [x] `new_reference_request_email_sent`
    # - [x] `new_reference_added` - `created_by` of the third reference?
    # - [x] `references_complete` - from audit trail when `ApplicationForm#references_completed` gets set to true? (can happen more than once)

    # - [ ] `waiting_to_be_sent_to_provider` - not sure what this one means
    # - [ ] `application_sent_to_provider` - `ApplicationChoice#sent_to_provider_at`
    # - [ ] `awaiting_decision` QUESTION - not sure what this means (isn't it the same as `sent_to_provider_at`?)
    # - [ ] `rbd_date` - `ApplicationChoice#sent_to_provider_at`
    # - [ ] `rbd_reminder_sent` - Is this the `chase_provider_decision` email? `ChaserSent#provider_decision_request` ?
    # - [ ] `application_rbd` - Combination of `ApplicationChoice#rejected_at` and `rejected_by_default`
    # - [ ] `provider_decision` (Reject/Offer) - `ApplicationChoice#rejected_at` or `ApplicationChoice#offered_at`
    # - [ ] `offer_made` awaiting decision from candidate - `ApplicationChoice#offered_at`
    # - [ ] `email_sent_to_candidate` - the offer email? also the reject email?
    # - [ ] `dbd_date` - `ApplicationChoice#decline_by_default_at`
    # - [ ] `dbd_reminder_email` - `ChaserSent#chaser_type`
    # - [ ] `candidate_decision` (accept/decline) - `ApplicationChoice#accepted_at` or `ApplicationChoice#declined_at`
    # - [ ] `offer_declined` - `ApplicationChoice#declined_at`
    # - [ ] `offer_accepted` - `ApplicationChoice#accepted_at`
    # - [ ] `email_sent_to_candidate_2` - the offer accepted email? QUESTION
    # - [ ] `pending_conditions` - from audit trail
    # - [ ] `conditions_outcome` - from audit trail
    # - [ ] `conditions_met` - from audit trail
    # - [ ] `conditions_not_met` - from audit trail
    # - [ ] `enrolled` - from audit trail
    # - [ ] `ended_without_success` - from audit trail?
    # - [ ] `send_rejection_email` - from emails?
  end
end
