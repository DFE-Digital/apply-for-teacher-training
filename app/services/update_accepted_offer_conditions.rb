class UpdateAcceptedOfferConditions
  def initialize(application_choice:, update_conditions_service:, audit_comment_ticket:)
    @application_choice = application_choice
    @update_conditions_service = update_conditions_service
    @audit_comment_ticket = audit_comment_ticket
  end

  def save!
    ActiveRecord::Base.transaction do
      conditions = @update_conditions_service.conditions
      @application_choice.update(
        audit_comment: "Change offer condition Zendesk request: #{@audit_comment_ticket}",
      )
      @update_conditions_service.save
      if conditions.empty?
        ApplicationStateChange.new(@application_choice).confirm_conditions_met!
        @application_choice.update!(recruited_at: Time.zone.now)
      end
    end

    StateChangeNotifier.new(:recruited, @application_choice).application_outcome_notification

    true
  rescue Workflow::NoTransitionAllowed
    false
  end
end
