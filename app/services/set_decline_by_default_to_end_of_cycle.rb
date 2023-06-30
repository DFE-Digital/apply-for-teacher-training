class SetDeclineByDefaultToEndOfCycle
  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def call
    return unless @application_choice.offer?

    @application_choice.update!(
      decline_by_default_at: CycleTimetable.next_apply_deadline,
    )
  end
end
