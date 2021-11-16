Holidays.between(Date.civil(2019, 1, 1), 2.years.from_now, :gb_eng, :observed).map do |holiday|
  BusinessTime::Config.holidays << holiday[:date]
end

Rails.application.reloader.to_prepare do # req'd when autoloading in initializer
  CycleTimetable.holidays.each_value do |date_range|
    BusinessTime::Config.holidays += date_range.to_a
  end
end

BusinessTime::Config.beginning_of_workday = '0:00 am'
BusinessTime::Config.end_of_workday = '11:59:59 pm'
