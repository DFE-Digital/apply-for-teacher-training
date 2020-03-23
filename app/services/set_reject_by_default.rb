class SetRejectByDefault
  attr_reader :application_choice

  def initialize(application_choice)
    @application_choice = application_choice
  end

  def call
    time_limit = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date: application_choice.sent_to_provider_at,
    ).call

    days = time_limit[:days]
    time = time_limit[:time_in_future]

    application_choice.update!(
      reject_by_default_at: time,
      reject_by_default_days: days,
    )
  end
end
