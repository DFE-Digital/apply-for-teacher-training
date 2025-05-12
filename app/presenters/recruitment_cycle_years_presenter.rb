class RecruitmentCycleYearsPresenter
  def self.call(start_year: 2020, end_year: RecruitmentCycleTimetable.current_year, with_current_indicator: false)
    new(start_year, end_year, with_current_indicator:).call
  end

  def initialize(start_year, end_year = nil, with_current_indicator: false)
    @start_year = start_year.to_i
    @end_year = end_year&.to_i || start_year.to_i
    @with_current_indicator = with_current_indicator
  end

  attr_reader :start_year, :end_year, :with_current_indicator

  def call
    return {} if start_year < 2020
    return {} if end_year < start_year

    end_year.downto(start_year).index_with do |year|
      cycle_string(year)
    end.stringify_keys
  end

private

  def cycle_string(year)
    cycle_range = "#{year - 1} to #{year}"

    if with_current_indicator && year.to_i == current_year
      "#{cycle_range} - current"
    else
      cycle_range
    end
  end

  def current_year
    @current_year ||= RecruitmentCycleTimetable.current_year
  end
end
