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

    dbd_time_limit = TimeLimitCalculator.new(
      rule: :decline_by_default,
      effective_date: most_recent_decision_date,
    ).call

    dbd_days = dbd_time_limit[:days]
    dbd_time = dbd_time_limit[:time_in_future]

    application_choices.where(status: 'offer').update_all(
      decline_by_default_at: dbd_time,
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
