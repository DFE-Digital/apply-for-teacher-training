Holidays.between(Date.civil(2019, 1, 1), 2.years.from_now, :gb_eng, :observed).map do |holiday|
  BusinessTime::Config.holidays << holiday[:date]
end

UCAS_COVID_DATE_FREEZE = (Date.new(2020, 3, 23)..Date.new(2020, 5, 28)).freeze
UCAS_WINTER_HOLIDAY_2020 = (Date.new(2020, 12, 20)..Date.new(2021, 1, 1)).freeze
UCAS_SPRING_HOLIDAY_2021 = (Date.new(2021, 4, 2)..Date.new(2021, 4, 16)).freeze

UCAS_HOLIDAYS = UCAS_COVID_DATE_FREEZE.to_a + UCAS_WINTER_HOLIDAY_2020.to_a + UCAS_SPRING_HOLIDAY_2021.to_a

UCAS_HOLIDAYS.each do |date|
  BusinessTime::Config.holidays << date
end

BusinessTime::Config.beginning_of_workday = '0:00 am'
BusinessTime::Config.end_of_workday = '11:59:59 pm'
