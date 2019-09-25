Given('there are no holidays') do
  $initialized_holidays = BusinessTime::Config.holidays.dup
  BusinessTime::Config.holidays.clear
end

# Restore any initialised holidays
After do
  BusinessTime::Config.holidays.replace($initialized_holidays) if defined?($initialized_holidays)
end

Given('the following dates are holidays:') do |table|
  $initialized_holidays = BusinessTime::Config.holidays.dup

  holiday_dates = table.raw.flatten.map { |str| Date.parse(str) }
  BusinessTime::Config.holidays.replace(holiday_dates)
end

Given('the following decision timeframes:') do |table|
  table.hashes.each do |row|
    timeframe_class = (row['type'] + ' timeframe').gsub(' ', '_').classify.constantize
    timeframe_class.create!(
      from_time: DateTime.parse(row['application submitted after']),
      to_time: DateTime.parse(row['application submitted before']),
      number_of_working_days: row['# of working days'],
    )
  end
end

Given('its RBD time is set to {string}') do |rbd_time|
  @application.update(rejected_by_default_at: rbd_time)
end

Then('working days are defined as follows:') do |table|
  table.hashes.each do |row|
    date = Date.parse(row['Date'])

    expect(date.strftime('%A')).to eq(row['Day of the week?'])
    expect(WorkingDay.is_working_day?(date)).to(row['Working day?'] == 'Y' ? be_truthy : be_falsey)
  end
end
