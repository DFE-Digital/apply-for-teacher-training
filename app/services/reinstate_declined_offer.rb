class ReinstateDeclinedOffer
  def initialize(course_choice:, zendesk_ticket:)
    @course_choice = course_choice
    @zendesk_ticket = zendesk_ticket
  end

  def save!
    @course_choice.update!(
      status: 'offer',
      declined_at: nil,
      withdrawn_or_declined_for_candidate_by_provider: nil,
      audit_comment: "Reinstate offer Zendesk request: #{@zendesk_ticket}",
    )
  end
end
