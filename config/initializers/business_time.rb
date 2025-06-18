Holidays.between(Date.civil(2019, 1, 1), 2.years.from_now, :gb_eng, :observed).map do |holiday|
  BusinessTime::Config.holidays << holiday[:date]
end

((Time.zone.now.year - 1)..2.years.from_now.year).to_a.each do |year|
  extra_christmas_holiday_range = Date.new(year, 12, 27)..Date.new(year, 12, 31)
  BusinessTime::Config.holidays += extra_christmas_holiday_range.to_a
end

BusinessTime::Config.beginning_of_workday = '0:00 am'
BusinessTime::Config.end_of_workday = '11:59:59 pm'
