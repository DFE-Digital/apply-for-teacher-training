Then("working days are defined as follows:") do |table|
  table.hashes.each do |row|
    date = Date.parse(row["Date"])

    expect(date.strftime("%A")).to eq(row["Day of the week?"])
    expect(WorkingDay.is_working_day?(date)).to (row["Working day?"] == 'Y' ? be_truthy : be_falsey)
  end
end
