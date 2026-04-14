require 'rails_helper'

RSpec.describe Publications::RegionalEdiReportWorker do
  before do
    @instance = instance_double(
      Publications::RegionalEdiReportGenerator,
      call: nil,
    )
    allow(Publications::RegionalEdiReportGenerator).to receive(:new)
      .and_return(@instance)
  end

  let(:cycle_week) { current_cycle_week.pred }
  let(:region) { 'London' }
  let(:generation_date) { RecruitmentPerformanceReportTimetable.current_generation_date }
  let(:publication_date) { RecruitmentPerformanceReportTimetable.current_generation_date }
  let(:recruitment_cycle_year) { 2026 }

  describe '#perform' do
    it 'calls the regional edi report generator' do
      described_class.new.perform(cycle_week, region, recruitment_cycle_year)

      expect(@instance).to have_received(:call)
      expect(Publications::RegionalEdiReportGenerator).to have_received(:new).with(
        cycle_week:,
        region:,
        generation_date:,
        publication_date:,
        recruitment_cycle_year:,
      )
    end
  end
end
