require 'rails_helper'

RSpec.describe DataMigrations::PopulateApplicationChoiceCurrentRecruitmentCycleYear do
  let!(:application_choice) { create(:application_choice) }
  let!(:application_choice_previous_year) { create(:application_choice, :previous_year) }

  it 'sets current_recruitment_cycle_year' do
    ApplicationChoice.update_all(current_recruitment_cycle_year: nil)

    described_class.new.change

    expected_years = [RecruitmentCycle.current_year, RecruitmentCycle.previous_year]
    years = ApplicationChoice.order('id').all.map(&:current_recruitment_cycle_year)
    expect(years).to eq(expected_years)
  end
end
