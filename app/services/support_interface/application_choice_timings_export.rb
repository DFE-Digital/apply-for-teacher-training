module SupportInterface
  class ApplicationChoiceTimingsExport
    def application_choices
      all_application_choices.map do |choice|
        {
          id: choice.id,
          status: choice.status,
          candidate_id: choice.application_form.candidate_id,
          support_reference: choice.application_form.support_reference,
          phase: choice.application_form.phase,
          form_not_started: nil, # - created_at?
          form_started_and_not_submitted: nil, # - (and not submitted) first audit trail update?
          submitted_and_awaiting_references: nil, # - submitted_at
          reference_1_received: nil, # - from audit trail (reference status change)?
          reference_2_recieved: nil, # - from audit trail (reference status change)?
          reference_reminder_email_sent: nil, # - from chasers sent (chaser_type: :reference_request)
          new_reference_request_email_sent: nil, # - emails?
          new_reference_added: nil, # - ?
          references_complete: nil, # - from audit trail when `ApplicationForm#references_completed` gets set to true? (can happen more than once)
          waiting_to_be_sent_to_provider: nil, # - not sure what this one means
          application_sent_to_provider: nil, # - `ApplicationChoice#sent_to_provider_at`
          awaiting_decision: nil, # QUESTION - not sure what this means (isn't it the same as `sent_to_provider_at`?)
          rbd_date: nil, # - `ApplicationChoice#sent_to_provider_at`
          rbd_reminder_sent: nil, # - Is this the `chase_provider_decision` email? `ChaserSent#provider_decision_request` ?
          application_rbd: nil, # - Combination of `ApplicationChoice#rejected_at` and `rejected_by_default`
          provider_decision: nil, # (Reject/Offer) - `ApplicationChoice#rejected_at` or `ApplicationChoice#offered_at`
          offer_made: nil, # awaiting decision from candidate - `ApplicationChoice#offered_at`
          email_sent_to_candidate: nil, # - the offer email? also the reject email?
          dbd_date: nil, # - `ApplicationChoice#decline_by_default_at`
          dbd_reminder_email: nil, # - `ChaserSent#chaser_type`
          candidate_decision: nil, # (accept/decline) - `ApplicationChoice#accepted_at` or `ApplicationChoice#declined_at`
          offer_declined: nil, # - `ApplicationChoice#declined_at`
          offer_accepted: nil, # - `ApplicationChoice#accepted_at`
          email_sent_to_candidate_2: nil, # - the offer accepted email? QUESTION
          pending_conditions: nil, # - from audit trail
          conditions_outcome: nil, # - from audit trail
          conditions_met: nil, # - from audit trail
          conditions_not_met: nil, # - from audit trail
          enrolled: nil, # - from audit trail
          ended_without_success: nil, # - audit trail?
          send_rejection_email: nil, # - emails?
        }
      end
    end

  private

    def all_application_choices
      ApplicationChoice
        .includes(
          application_form: %i[candidate],
        )
        .joins(:application_form)
        .order('application_forms.submitted_at asc, application_forms.id asc, id asc')
    end
  end
end
