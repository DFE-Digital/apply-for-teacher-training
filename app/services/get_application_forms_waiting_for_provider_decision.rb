class GetApplicationFormsWaitingForProviderDecision
  def self.call
    ApplicationChoice
      .where(status: :awaiting_provider_decision)
      .where('reject_by_default_at < ?', chase_provider_time_limit)
      .where.not(id: ChaserSent.provider_decision_request.select(:chased_id))
  end

  def self.chase_provider_time_limit
    TimeLimitCalculator.new(rule: :chase_provider_before_rbd, effective_date: Time.zone.now).call.second
  end
end
