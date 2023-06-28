class SetDeclineByDefaultToEndOfCycle
  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    # Only set Decline by Default (DBD) date if all applications have been acted upon.
    return if pending_decisions?

    application_choices.offer.each do |application_choice|
      next if application_choice.decline_by_default_at == CycleTimetable.next_apply_deadline

      application_choice.update!(
        decline_by_default_at: CycleTimetable.next_apply_deadline,
      )
    end
  end

private

  attr_reader :application_form

  def application_choices
    application_form.application_choices
  end

  def pending_decisions?
    application_form.awaiting_provider_decisions?
  end
end
