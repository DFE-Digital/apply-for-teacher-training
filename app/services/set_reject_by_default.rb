class SetRejectByDefault
  attr_reader :application_choice

  def initialize(application_choice)
    @application_choice = application_choice
  end

  def call
    time_limit = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date: Time.zone.now,
    ).call

    days = time_limit[:days]
    time = time_limit[:time_in_future]

    application_choice.reject_by_default_days = days
    application_choice.reject_by_default_at = time
    application_choice.save!
  end
end
