require 'rails_helper'

RSpec.describe DataMigrations::AddRecruitmentCycleYearToPerformanceReports do
  let(:start_of_2025_cycle) { RecruitmentCycleTimetable.find_by(recruitment_cycle_year: 2025).find_opens_at }

  before do
    DataMigrations::AddAllRecruitmentCycleTimetablesToDatabase.new.change
  end

  it 'only updates provider report recruitment cycle year for publications before 2025' do
    provider_report_from_2024 = create(
      :provider_recruitment_performance_report, recruitment_cycle_year: 2025, created_at: start_of_2025_cycle - 1.day
    )
    provider_report_from_2025 = create(
      :provider_recruitment_performance_report, recruitment_cycle_year: 2025, created_at: start_of_2025_cycle + 1.day
    )

    described_class.new.change

    expect(provider_report_from_2024.reload.recruitment_cycle_year).to eq 2024
    expect(provider_report_from_2025.reload.recruitment_cycle_year).to eq 2025
  end

  it 'only updates national report recruitment cycle year for publications before 2025' do
    national_report_from_2024 = create(:national_recruitment_performance_report, recruitment_cycle_year: 2025, created_at: start_of_2025_cycle - 1.day)
    national_report_from_2025 = create(:national_recruitment_performance_report, recruitment_cycle_year: 2025, created_at: start_of_2025_cycle + 1.day)

    described_class.new.change

    expect(national_report_from_2024.reload.recruitment_cycle_year).to eq 2024
    expect(national_report_from_2025.reload.recruitment_cycle_year).to eq 2025
  end
end
