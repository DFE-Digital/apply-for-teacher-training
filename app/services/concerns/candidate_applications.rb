module CandidateApplications
  def applications_with_offer_and_awaiting_decision?
    applications_with_offer_count == 1 && applications_awaiting_decision_count == 1
  end

  def applications_with_offers_only?
    applications_with_offer_count.positive? && applications_awaiting_decision_count.zero?
  end

  def applications_awaiting_decision_only?
    applications_awaiting_decision_count.positive? && applications_with_offer_count.zero?
  end

  def applications_awaiting_decision_count
    @applications_pending_decision_count ||= candidate_applications.decision_pending.count
  end

  def applications_with_offer_count
    @applications_with_offer_count ||= candidate_applications.offer.count
  end

  def candidate_applications
    @candidate_applications ||= @application_choice.self_and_siblings
  end
end
