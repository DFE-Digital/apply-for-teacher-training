require 'rails_helper'

RSpec.describe Publications::NationalRecruitmentPerformanceReportWorker do
  before do
    @instance = instance_double(Publications::NationalRecruitmentPerformanceReportGenerator, call: nil)
    allow(Publications::NationalRecruitmentPerformanceReportGenerator).to receive(:new).and_return(@instance)
  end

  let(:cycle_week) { current_cycle_week.pred }
  let(:generation_date) { RecruitmentPerformanceReportTimetable.current_generation_date }
  let(:publication_date) { RecruitmentPerformanceReportTimetable.current_generation_date }

  describe '#perform' do
    it 'calls the National Report Generator' do
      described_class.new.perform(cycle_week)

      expect(@instance).to have_received(:call)
      expect(Publications::NationalRecruitmentPerformanceReportGenerator).to have_received(:new).with(cycle_week:, generation_date:, publication_date:)
    end
  end
end
