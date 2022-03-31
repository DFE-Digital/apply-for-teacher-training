class ProviderInterface::KeyDatesBanner < ViewComponent::Base
  def render?
    CycleTimetable.show_non_working_days_banner?
  end

  def non_working_days_period
    "#{holiday_period.first.to_fs(:day_and_month)} to #{holiday_period.last.to_fs(:govuk_date)}"
  end

  def holiday_name
    if CycleTimetable.show_christmas_non_working_days_banner?
      :christmas
    elsif CycleTimetable.show_easter_non_working_days_banner?
      :easter
    end
  end

private

  def holiday_period
    CycleTimetable.holidays[holiday_name]
  end
end
