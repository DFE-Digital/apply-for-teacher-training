class ProviderInterface::KeyDatesBanner < ViewComponent::Base
  def render?
    render_deadline_banner?
  end

  def non_working_days_period
    "#{christmas_period.first.to_fs(:govuk_date)} to #{christmas_period.last.to_fs(:govuk_date)}"
  end

private

  def render_deadline_banner?
    CycleTimetable.show_non_working_days_deadline_banner?
  end

  def christmas_period
    CycleTimetable.holidays[:christmas]
  end
end
