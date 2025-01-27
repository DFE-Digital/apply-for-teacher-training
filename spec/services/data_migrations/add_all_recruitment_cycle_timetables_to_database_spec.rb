require 'rails_helper'

RSpec.describe DataMigrations::AddAllRecruitmentCycleTimetablesToDatabase do
  it 'adds all recruitment cycles to database' do
    described_class.new.change
    expect(RecruitmentCycleTimetable.pluck(:recruitment_cycle_year))
      .to contain_exactly(2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026, 2027)
  end

  it 'handles holidays as expected' do
    described_class.new.change
    year_without_holidays = RecruitmentCycleTimetable.find_by(recruitment_cycle_year: 2020)
    year_with_holidays = RecruitmentCycleTimetable.find_by(recruitment_cycle_year: 2021)

    expect(year_without_holidays.easter_holiday_range).to be_nil
    expect(year_without_holidays.christmas_holiday_range).to be_nil

    expect(year_with_holidays.easter_holiday_range.begin).to eq Date.new(2021, 4, 2)
    expect(year_with_holidays.easter_holiday_range.end).to eq Date.new(2021, 4, 17)

    expect(year_with_holidays.christmas_holiday_range.begin).to eq Date.new(2020, 12, 20)
    expect(year_with_holidays.christmas_holiday_range.end).to eq Date.new(2021, 1, 2)
  end

  it 'does not create duplicates if run twice' do
    described_class.new.change
    expect(RecruitmentCycleTimetable.count).to eq 9
    described_class.new.change
    expect(RecruitmentCycleTimetable.count).to eq 9
  end

  it 'reverts any changes to the original data' do
    described_class.new.change
    timetable = RecruitmentCycleTimetable.last
    original_find_opens_at = timetable.find_opens_at

    timetable.update(find_opens_at: original_find_opens_at - 1.day)
    described_class.new.change
    expect(timetable.reload.find_opens_at).to eq original_find_opens_at
  end
end
