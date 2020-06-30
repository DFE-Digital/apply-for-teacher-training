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
      earliest_reference_chaser_sent(:reference_request)
    end

    def new_reference_request_email_sent
      earliest_reference_chaser_sent(:reference_replacement)
    end

    def new_reference_added
      references_created_at = all_references.map(&:created_at).sort
      references_created_at.size >= 2 ? references_created_at[2] : nil
    end

    def references_completed
      earliest_update_audit_for(@application_choice.application_form, references_completed: true)
    end

    def waiting_to_be_sent_to_provider
      earliest_update_audit_for(@application_choice, status: 'application_complete')
    end

    def application_sent_to_provider
      @application_choice.sent_to_provider_at
    end

    def rbd_date
      @application_choice.reject_by_default_at
    end

    def rbd_reminder_sent
      earliest_application_chaser_sent(:provider_decision_request)
    end

    def application_rbd
      @application_choice.rejected_by_default ? @application_choice.rejected_at : nil
    end

    def pending_conditions
      @application_choice.accepted_at
    end

    def provider_decision
      @application_choice.offered_at || @application_choice.rejected_at
    end

    def offer_made
      @application_choice.offered_at
    end

    def dbd_date
      @application_choice.decline_by_default_at
    end

    def dbd_reminder_sent
      earliest_application_chaser_sent(:candidate_decision_request)
    end

    def candidate_decision
      @application_choice.accepted_at || @application_choice.declined_at
    end

    def offer_declined
      @application_choice.declined_at
    end

    def offer_accepted
      @application_choice.accepted_at
    end

    def conditions_outcome
      @application_choice.recruited_at || @application_choice.conditions_not_met_at
    end

    def conditions_met
      @application_choice.recruited_at
    end

    def conditions_not_met
      @application_choice.conditions_not_met_at
    end

    def enrolled
      @application_choice.enrolled_at
    end

    def ended_without_success
      earliest_update_audit_for(
        @application_choice,
        status: ApplicationStateChange::UNSUCCESSFUL_END_STATES,
      )
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
            if value.is_a?(Array)
              change && value.include?(change[1])
            else
              change && change[1] == value
            end
          end
      end

      audits.map(&:created_at).min
    end

    def earliest_reference_chaser_sent(chaser_type)
      chasers = @application_choice.application_form.application_references.map(&:chasers_sent).flatten
      chasers.select { |chaser| chaser.chaser_type == chaser_type.to_s }.map(&:created_at).min
    end

    def earliest_application_chaser_sent(chaser_type)
      chasers = @application_choice.chasers_sent
      chasers.select { |chaser| chaser.chaser_type == chaser_type.to_s }.map(&:created_at).min
    end
  end
end
