require 'rails_helper'

RSpec.describe DataMigrations::AddAllRecruitmentCycleTimetablesToDatabase do
  it 'adds all recruitment cycles to database' do
    described_class.new.change
    expect(
      RecruitmentCycleTimetable.pluck(:recruitment_cycle_year),
    ).to contain_exactly(2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026, 2027)
    expect(
      RecruitmentCycleTimetable.where(real_timetable: true).pluck(:recruitment_cycle_year),
    ).to contain_exactly(2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026, 2027)
  end

  it 'handles holidays as expected' do
    described_class.new.change
    year_without_holidays = RecruitmentCycleTimetable.find_by(recruitment_cycle_year: 2020)
    year_with_holidays = RecruitmentCycleTimetable.find_by(recruitment_cycle_year: 2021)

    expect(year_without_holidays.easter_holiday).to be_nil
    expect(year_without_holidays.christmas_holiday).to be_nil

    expect(year_with_holidays.easter_holiday.begin).to eq Date.new(2021, 4, 2)
    expect(year_with_holidays.easter_holiday.end).to eq Date.new(2021, 4, 17)

    expect(year_with_holidays.christmas_holiday.begin).to eq Date.new(2020, 12, 20)
    expect(year_with_holidays.christmas_holiday.end).to eq Date.new(2021, 1, 2)
  end
end
