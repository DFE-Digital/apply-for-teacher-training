class RecalculateDates
  include Sidekiq::Worker

  def perform(*)
    application_choices = ApplicationChoice.where(status: :awaiting_provider_decision).includes(:application_form)
    application_choices.find_each do |application_choice|
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
  end
end
