require 'rails_helper'

RSpec.describe Publications::ProviderRecruitmentPerformanceReportWorker do
  before do
    @instance = instance_double(Publications::ProviderRecruitmentPerformanceReportGenerator, call: nil)
    allow(Publications::ProviderRecruitmentPerformanceReportGenerator).to receive(:new).and_return(@instance)
  end

  let(:cycle_week) { current_cycle_week.pred }
  let(:generation_date) { RecruitmentPerformanceReportTimetable.current_generation_date }
  let(:publication_date) { RecruitmentPerformanceReportTimetable.current_generation_date }
  let(:provider_id) { create(:provider).id }
  let(:recruitment_cycle_year) { 2026 }

  describe '#perform' do
    it 'calls the Provider Report Generator' do
      described_class.new.perform(provider_id, cycle_week, recruitment_cycle_year)

      expect(@instance).to have_received(:call)
      expect(Publications::ProviderRecruitmentPerformanceReportGenerator).to have_received(:new).with(
        cycle_week:,
        generation_date:,
        publication_date:,
        provider_id:,
        recruitment_cycle_year:,
      )
    end
  end
end
