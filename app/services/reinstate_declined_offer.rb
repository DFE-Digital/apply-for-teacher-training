class ReinstateDeclinedOffer
  def initialize(course_choice:, zendesk_ticket:)
    @course_choice = course_choice
    @zendesk_ticket = zendesk_ticket
  end

  def save!
    reset_all_dbd

    @course_choice.update!(
      status: 'offer',
      declined_at: nil,
      decline_by_default_at: set_dbd_value,
      audit_comment: "Reinstate offer Zendesk request: #{@zendesk_ticket}",
    )
  end

private

  def reset_all_dbd
    choices_to_reset.each do |choice|
      choice.update!(
        decline_by_default_at: set_dbd_value,
        audit_comment: "DBD reset due to a reinstated offer on application choice #{@course_choice.id} from ticket: #{@zendesk_ticket}",
      )
    end
  end

  def choices_to_reset
    @course_choice.self_and_siblings.where(status: 'offer').where.not(id: @course_choice.id)
  end

  def set_dbd_value
    TimeLimitCalculator.new(rule: :decline_by_default, effective_date: Time.zone.now).call[:time_in_future]
  end
end
