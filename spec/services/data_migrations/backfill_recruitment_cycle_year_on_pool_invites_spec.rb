require 'rails_helper'

RSpec.describe DataMigrations::BackfillRecruitmentCycleYearOnPoolInvites do
  it 'updates all pool invites without a recruitment cycle year' do
    without_year = create(:pool_invite, recruitment_cycle_year: nil)
    with_year = create(:pool_invite, recruitment_cycle_year: previous_year)

    described_class.new.change

    expect(without_year.reload.recruitment_cycle_year).to eq current_year
    expect(with_year.reload.recruitment_cycle_year).to eq previous_year
  end
end
