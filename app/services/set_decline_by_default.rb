class SetDeclineByDefault
  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    return false if pending_decisions? || no_offers?

    most_recent_decision_date = [
      application_choices.maximum(:offered_at),
      application_choices.maximum(:rejected_at),
      application_choices.maximum(:withdrawn_at),
    ].compact.max

    dbd_days = TimeLimitCalculator.new(
      rule: :decline_by_default,
      effective_date: most_recent_decision_date,
    ).call

    dbd_date = dbd_days.business_days.after(most_recent_decision_date).end_of_day

    application_choices.where('status = \'offer\' AND decline_by_default_at IS NULL').update_all(
      decline_by_default_at: dbd_date,
      decline_by_default_days: dbd_days,
    )
  end

private

  attr_reader :application_form

  def application_choices
    application_form.application_choices
  end

  def pending_decisions?
    application_form.awaiting_provider_decisions?
  end

  def no_offers?
    application_choices.where(status: :offer).none?
  end
end
