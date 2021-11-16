module MonthlyStatisticsTimetable
  # Currently, this uses the 3rd Monday of each month as agreed with Mike.
  # It's not ideal, and may well change at a later date.
  # It's also not cycle aware and will be needed to be updated yearly.

  GENERATION_DATES = {
    'October' => Date.new(RecruitmentCycle.previous_year, 10, 18),
    'November' => Date.new(RecruitmentCycle.previous_year, 11, 22),
    'December' => Date.new(RecruitmentCycle.previous_year, 12, 20),
    'January' => Date.new(RecruitmentCycle.current_year, 1, 17),
    'February' => Date.new(RecruitmentCycle.current_year, 2, 21),
    'March' => Date.new(RecruitmentCycle.current_year, 3, 21),
    'April' => Date.new(RecruitmentCycle.current_year, 4, 18),
    'May' => Date.new(RecruitmentCycle.current_year, 5, 16),
    'June' => Date.new(RecruitmentCycle.current_year, 6, 20),
    'July' => Date.new(RecruitmentCycle.current_year, 7, 18),
    'August' => Date.new(RecruitmentCycle.current_year, 8, 15),
    'September' => Date.new(RecruitmentCycle.current_year, 9, 19),
  }.freeze

  def self.generate_monthly_statistics?
    Time.zone.today == GENERATION_DATES[Date::MONTHNAMES[Time.zone.today.month]]
  end

  def self.latest_report_date
    report_date_for_current_month = GENERATION_DATES[Date::MONTHNAMES[Time.zone.today.month]]

    if report_date_for_current_month > Time.zone.today
      return_last_months_generation_date
    else
      return_current_months_generation_date
    end
  end

  def self.return_last_months_generation_date
    GENERATION_DATES[Date::MONTHNAMES[(Time.zone.today - 1.month).month]]
  end

  def self.return_current_months_generation_date
    GENERATION_DATES[Date::MONTHNAMES[Time.zone.today.month]]
  end
end
