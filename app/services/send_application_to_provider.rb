# This worker will be scheduled to run nightly
class SendApplicationToProvider
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    # set_reject_by_default(application_choice)
    ApplicationStateChange.new(application_choice).send_to_provider!
  end

private

  def set_reject_by_default
    days = TimeLimitCalculator.new(
      :reject_by_default,
      Time.zone.now,
    ).call
    application_choice.reject_by_default_at = days.business_days.from_now
  end
end
