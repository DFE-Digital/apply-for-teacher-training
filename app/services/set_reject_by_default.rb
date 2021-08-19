class SetRejectByDefault
  attr_reader :application_choice, :effective_date

  def initialize(application_choice)
    @application_choice = application_choice
    @effective_date = application_choice.sent_to_provider_at
  end

  def call
    time_limit = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date: effective_date,
    ).call

    days = time_limit[:days]
    time = time_limit[:time_in_future]

    return if application_choice.reject_by_default_at.to_s == time.in_time_zone.to_s &&
              application_choice.reject_by_default_days == days

    rbd_date = beyond_eoc?(time) ? eoc_rbd_date : time

    application_choice.update!(
      reject_by_default_at: rbd_date,
      reject_by_default_days: days,
    )
  end

private

  def beyond_eoc?(date)
    date >= CycleTimetable.find_closes
  end

  def eoc_rbd_date
    1.business_days.before(CycleTimetable.find_closes).end_of_day
  end
end
