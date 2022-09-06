class SetRejectByDefault
  attr_reader :application_choice, :effective_date

  def initialize(application_choice)
    @application_choice = application_choice
    @effective_date = application_choice.sent_to_provider_at
  end

  def call
    time_limit = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date:,
    ).call

    days = time_limit[:days]
    time = time_limit[:time_in_future]

    return if application_choice.reject_by_default_at.to_s == time.in_time_zone.to_s &&
              application_choice.reject_by_default_days == days

    rbd_date = beyond_end_of_cycle_reject_by_default_deadline?(time) ? reject_by_default_date : time

    application_choice.update!(
      reject_by_default_at: rbd_date,
      reject_by_default_days: days,
    )
  end

private

  def beyond_end_of_cycle_reject_by_default_deadline?(date)
    # keep RBD the same on Sandbox so we can keep Apply open for testing
    return false if HostingEnvironment.sandbox_mode?

    date >= reject_by_default_date
  end

  def reject_by_default_date
    0.business_days.before(CycleTimetable.reject_by_default).end_of_day
  end
end
