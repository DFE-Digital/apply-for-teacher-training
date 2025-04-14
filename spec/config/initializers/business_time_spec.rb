require 'rails_helper'

RSpec.describe 'Holidays added to business time configuration' do
  it 'includes the two week period including Good Friday and Easter in the holidays' do
    good_fridays = Holidays.between(Date.civil(2019, 1, 1), 2.years.from_now, :gb_eng, :observed).filter do |holiday|
      holiday[:name] == 'Good Friday'
    end

    good_fridays.each do |good_friday|
      monday_before = good_friday[:date].prev_occurring(:monday)
      friday_after = good_friday[:date].next_occurring(:friday)
      easter_holiday_range = (monday_before..friday_after).to_a
      expect(easter_holiday_range.length).to eq 12
      easter_holiday_range.each do |easter_holiday_day|
        expect(BusinessTime::Config.holidays).to include easter_holiday_day
      end
    end
  end

  it 'includes 20 days inclusive of new years and christmas' do
    new_years_days = Holidays.between(Date.civil(2019, 1, 1), 2.years.from_now, :gb_eng, :observed).filter do |holiday|
      holiday[:name] == "New Year's Day"
    end

    new_years_days.each do |new_years_day|
      friday_after = new_years_day[:date].next_occurring(:friday)
      before_christmas = friday_after - 19.days
      christmas_range = (before_christmas..friday_after).to_a
      expect(christmas_range.length).to eq 20
      christmas_range.each do |christmas_holiday_day|
        expect(BusinessTime::Config.holidays).to include christmas_holiday_day
      end
    end
  end
end
