require 'rails_helper'

RSpec.describe Publications::ProviderEdiReportWorker do
  before do
    @instance = instance_double(
      Publications::ProviderEdiReportGenerator,
      call: nil,
    )
    allow(Publications::ProviderEdiReportGenerator).to receive(:new)
      .and_return(@instance)
  end

  let(:provider_id) { 1 }
  let(:cycle_week) { current_cycle_week.pred }
  let(:category) { 'Sex' }
  let(:generation_date) { RecruitmentPerformanceReportTimetable.current_generation_date }
  let(:publication_date) { RecruitmentPerformanceReportTimetable.current_generation_date }

  describe '#perform' do
    it 'calls the provider edi report generator' do
      described_class.new.perform(provider_id, cycle_week, category)

      expect(@instance).to have_received(:call)
      expect(Publications::ProviderEdiReportGenerator).to have_received(:new).with(
        provider_id:,
        cycle_week:,
        category:,
        generation_date:,
        publication_date:,
      )
    end
  end
end
