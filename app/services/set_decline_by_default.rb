class SetDeclineByDefault
  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    # Only set Decline by Default (DBD) date if all applications have been acted upon.
    return if pending_decisions?

    # If there are not any offers we do not need to set a DBD date
    return if no_offers?

    # We only start counting the days for decline by default when all the candidate's
    # applications have either an offer, been rejected by provider, withdrawn by
    # the candidate, or have the offer withdrawn.
    final_decision_date = [
      application_choices.maximum(:offer_changed_at),
      application_choices.maximum(:offered_at),
      application_choices.maximum(:rejected_at),
      application_choices.maximum(:withdrawn_at),
      application_choices.maximum(:offer_withdrawn_at),
    ].compact.max

    dbd_time_limit = TimeLimitCalculator.new(
      rule: :decline_by_default,
      effective_date: final_decision_date.in_time_zone,
    ).call

    dbd_days = dbd_time_limit[:days]
    dbd_time = dbd_time_limit[:time_in_future]

    application_choices.where(status: 'offer').each do |application_choice|
      next if application_choice.decline_by_default_at.to_s == dbd_time.in_time_zone.to_s &&
              application_choice.decline_by_default_days == dbd_days

      application_choice.update!(
        decline_by_default_at: dbd_time,
        decline_by_default_days: dbd_days,
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

  def no_offers?
    application_choices.where(status: :offer).none?
  end
end
