require 'rails_helper'

RSpec.describe Publications::RegionalRecruitmentPerformanceReportWorker do
  before do
    @instance = instance_double(
      Publications::RegionalRecruitmentPerformanceReportGenerator,
      call: nil,
    )
    allow(Publications::RegionalRecruitmentPerformanceReportGenerator).to receive(:new)
      .and_return(@instance)
  end

  let(:cycle_week) { current_cycle_week.pred }
  let(:region) { 'London' }
  let(:generation_date) { RecruitmentPerformanceReportTimetable.current_generation_date }
  let(:publication_date) { RecruitmentPerformanceReportTimetable.current_generation_date }

  describe '#perform' do
    it 'calls the National Report Generator' do
      described_class.new.perform(cycle_week, region)

      expect(@instance).to have_received(:call)
      expect(Publications::RegionalRecruitmentPerformanceReportGenerator).to have_received(:new).with(
        cycle_week:,
        region:,
        generation_date:,
        publication_date:,
      )
    end
  end
end
