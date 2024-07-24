module SupportInterface
  class RevertWithdrawal < SimpleDelegator
    def initialize(application_choice:, zendesk_ticket:)
      __setobj__(application_choice)
      @application_choice = application_choice
      @zendesk_ticket = zendesk_ticket
      assign_revert_attrs
    end

  private

    attr_reader :application_choice, :zendesk_ticket

    def assign_revert_attrs
      @application_choice.tap do |ac|
        ac.assign_attributes(
          status: :awaiting_provider_decision,
          withdrawn_at: nil,
          withdrawal_feedback: nil,
          withdrawn_or_declined_for_candidate_by_provider: nil,
          audit_comment: "Support request after candidate withdrew their application in error: #{zendesk_ticket}",
          structured_withdrawal_reasons: [],
        )
      end
    end
  end
end
