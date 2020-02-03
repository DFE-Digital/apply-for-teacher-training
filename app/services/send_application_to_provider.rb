# This worker will be scheduled to run nightly
class SendApplicationToProvider
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    ActiveRecord::Base.transaction do
      set_reject_by_default
      ApplicationStateChange.new(application_choice).send_to_provider!
      StateChangeNotifier.call(:send_application_to_provider, application_choice: application_choice)
      SendNewApplicationEmailToProvider.new(application_choice: application_choice).call
    end
  end

private

  def set_reject_by_default
    days, time = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date: Time.zone.now,
    ).call

    application_choice.reject_by_default_days = days
    application_choice.reject_by_default_at = time
    application_choice.save!
  end
end
