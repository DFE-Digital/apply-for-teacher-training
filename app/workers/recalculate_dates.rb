class RecalculateDates
  include Sidekiq::Worker

  def perform(*)
    Audited.audit_class.as_user('RecalculateDates worker') do
      ApplicationChoice
        .where(status: :awaiting_provider_decision)
        .includes(:application_form)
        .find_each do |application_choice|
          update_reject_by_default(application_choice)
        end

      ApplicationChoice
        .where(status: :offer)
        .includes(:application_form)
        .find_each do |application_choice|
          update_decline_by_default(application_choice)
        end
    end
  end

private

  def update_reject_by_default(application_choice)
    time_limit = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date: application_choice.application_form.submitted_at,
    ).call

    days = time_limit[:days]
    time = time_limit[:time_in_future]

    application_choice.reject_by_default_days = days
    application_choice.reject_by_default_at = time
    application_choice.save!
  end

  def update_decline_by_default(application_choice)
    time_limit = TimeLimitCalculator.new(
      rule: :decline_by_default,
      effective_date: application_choice.offered_at,
    ).call

    days = time_limit[:days]
    time = time_limit[:time_in_future]

    application_choice.decline_by_default_days = days
    application_choice.decline_by_default_at = time
    application_choice.save!
  end
end
