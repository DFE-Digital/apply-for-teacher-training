class UpdateAcceptedOfferConditions
  def initialize(application_choice:, conditions:, audit_comment_ticket:)
    @application_choice = application_choice
    @conditions = conditions
    @audit_comment_ticket = audit_comment_ticket
  end

  def save!
    ActiveRecord::Base.transaction do
      @application_choice.update(
        offer: { conditions: @conditions },
        audit_comment: "Change offer condition Zendesk request: #{@audit_comment_ticket}",
      )
      if @conditions.empty?
        ApplicationStateChange.new(@application_choice).confirm_conditions_met!
        @application_choice.update!(recruited_at: Time.zone.now)
      end
    end

    StateChangeNotifier.new(:recruited, @application_choice).application_outcome_notification
  rescue Workflow::NoTransitionAllowed
    false
  end
end
