Given ("there are no holidays") do
  $initialized_holidays = BusinessTime::Config.holidays.dup
  BusinessTime::Config.holidays.clear
end

# Restore any initialised holidays
After do
  BusinessTime::Config.holidays.replace($initialized_holidays) if defined?($initialized_holidays)
end

Given("the following dates are holidays:") do |table|
  $initialized_holidays = BusinessTime::Config.holidays.dup

  holiday_dates = table.raw.flatten.map {|str| Date.parse(str)}
  BusinessTime::Config.holidays.replace(holiday_dates)
end

Given("the following rules around “reject by default” decision timeframes:") do |table|
  # table is a Cucumber::MultilineArgument::DataTable
  pending # Write code here that turns the phrase above into concrete actions
end

Then("working days are defined as follows:") do |table|
  table.hashes.each do |row|
    date = Date.parse(row["Date"])

    expect(date.strftime("%A")).to eq(row["Day of the week?"])
    expect(WorkingDay.is_working_day?(date)).to (row["Working day?"] == 'Y' ? be_truthy : be_falsey)
  end
end
