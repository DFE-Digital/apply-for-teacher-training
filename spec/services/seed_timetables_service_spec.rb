require 'rails_helper'

RSpec.describe SeedTimetablesService do
  context 'with csv input' do
    it 'seeds timetables' do
      RecruitmentCycleTimetable.destroy_all

      file = Rails.root.join('config/initializers/cycle_timetables.csv').read
      csv_input = CSV.parse(file, headers: true)

      described_class.new(csv_input).call

      expect(RecruitmentCycleTimetable.count).to eq 10
    end
  end

  context 'with api response input' do
    it 'seeds timetables' do
      RecruitmentCycleTimetable.destroy_all
      file = Rails.root.join('spec/examples/production_recruitment_cycle_timetables_api/fetch_all_recruitment_cycles.json').read
      json_input = JSON.parse(file)['data']
      described_class.new(json_input).call

      expect(RecruitmentCycleTimetable.count).to eq 10
    end
  end
end
