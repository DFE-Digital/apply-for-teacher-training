require 'rails_helper'

RSpec.describe ProductionRecruitmentCycleTimetablesAPI::SyncTimetablesWithProduction do
  subject(:sync_timetables) { described_class.new.call }

  let(:body) { Pathname.new(Rails.root.join('spec/examples/production_recruitment_cycle_timetables_api/fetch_all_recruitment_cycles.json')) }

  before do
    stub_request(:get, ProductionRecruitmentCycleTimetablesAPI::Client::BASE_URL)
      .to_return(
        status: 200,
        body: body.read,
        headers: { 'Content-Type' => 'application/json' },
      )
  end

  it 'adds timetables to the database' do
    RecruitmentCycleTimetable.destroy_all

    sync_timetables

    expect(RecruitmentCycleTimetable.count).to eq 10
  end

  it 'updates altered timetables to match production' do
    timetable = RecruitmentCycleTimetable.find_by(recruitment_cycle_year: 2025)
    original_reject_by_default_date = timetable.reject_by_default_at

    timetable.reject_by_default_at = original_reject_by_default_date - 1.day
    timetable.save!

    sync_timetables

    expect(timetable.reload.reject_by_default_at).to eq original_reject_by_default_date
  end
end
