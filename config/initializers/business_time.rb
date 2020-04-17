Holidays.between(Date.civil(2019, 1, 1), 2.years.from_now, :gb_eng, :observed).map do |holiday|
  BusinessTime::Config.holidays << holiday[:date]
end

(Date.new(2020, 3, 23)..Date.new(2020, 5, 28)).each do |date|
  BusinessTime::Config.holidays << date
end

BusinessTime::Config.beginning_of_workday = '0:00 am'
BusinessTime::Config.end_of_workday = '11:59 pm'
