# This worker will be scheduled to run nightly
class SendApplicationToProvider
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    set_reject_by_default
    ApplicationStateChange.new(application_choice).send_to_provider!
  end

private

  def set_reject_by_default
    days = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date: Time.zone.now,
    ).call
    return unless days

    application_choice.reject_by_default_at = days.business_days.from_now.end_of_day
  end
end
