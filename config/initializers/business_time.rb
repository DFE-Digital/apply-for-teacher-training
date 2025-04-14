Holidays.between(Date.civil(2019, 1, 1), 2.years.from_now, :gb_eng, :observed).map do |holiday|
  if holiday[:name] == 'Good Friday'
    holiday_start = holiday[:date].prev_occurring(:monday)
    holiday_end = holiday[:date].next_occurring(:friday)
    BusinessTime::Config.holidays += (holiday_start..holiday_end).to_a
  elsif holiday[:name] == "New Year's Day"
    holiday_end = holiday[:date].next_occurring(:friday)
    holiday_start = holiday_end - 19.days
    BusinessTime::Config.holidays += (holiday_start..holiday_end).to_a
  else
    BusinessTime::Config.holidays << holiday[:date]
  end
end

BusinessTime::Config.beginning_of_workday = '0:00 am'
BusinessTime::Config.end_of_workday = '11:59:59 pm'
