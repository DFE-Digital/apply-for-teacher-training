class GetApplicationChoicesWaitingForCandidateDecision
  def self.call
    ApplicationForm.where(
      id: ApplicationChoice
        .where(status: :offer)
        .where('decline_by_default_at < ?', chase_candidate_time_limit)
        .select(:application_form_id),
        ).where.not(id: ChaserSent.candidate_decision_request.select(:chased_id))
  end

  def self.chase_candidate_time_limit
    TimeLimitCalculator.new(rule: :chase_candidate_before_dbd, effective_date: Time.zone.now).call[:time_in_future]
  end
end
