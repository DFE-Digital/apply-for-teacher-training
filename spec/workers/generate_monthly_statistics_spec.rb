require 'rails_helper'

RSpec.describe GenerateMonthlyStatistics, sidekiq: true do
  describe '#perform' do
    context 'when the monthly statistics report should be generated' do
      before do
        allow(DataExporter).to receive(:perform_async).and_return true
        allow(MonthlyStatisticsTimetable).to receive(:generate_monthly_statistics?).and_return true
      end

      it 'generates the monthly stats' do
        expect(MonthlyStatisticsReport.count).to eq(0)

        described_class.new.perform

        expect(MonthlyStatisticsReport.count).to eq(1)
      end

      it 'generates the monthly statistics exports' do
        described_class.new.perform

        export_ids = DataExport.all.order(:id).map(&:id)

        expect(DataExporter).to have_received(:perform_async).with(SupportInterface::MonthlyStatisticsExports::CandidatesByStatusExport, export_ids[0], {})
        expect(DataExporter).to have_received(:perform_async).with(SupportInterface::MonthlyStatisticsExports::ApplicationsByStatusExport, export_ids[1], {})
        expect(DataExporter).to have_received(:perform_async).with(SupportInterface::MonthlyStatisticsExports::CandidatesByAgeGroupExport, export_ids[2], {})
        expect(DataExporter).to have_received(:perform_async).with(SupportInterface::MonthlyStatisticsExports::CandidatesBySexExport, export_ids[3], {})
        expect(DataExporter).to have_received(:perform_async).with(SupportInterface::MonthlyStatisticsExports::CandidatesByAreaExport, export_ids[4], {})
        expect(DataExporter).to have_received(:perform_async).with(SupportInterface::MonthlyStatisticsExports::ApplicationsByCourseAgeGroupExport, export_ids[5], {})
        expect(DataExporter).to have_received(:perform_async).with(SupportInterface::MonthlyStatisticsExports::ApplicationsByCourseTypeExport, export_ids[6], {})
        expect(DataExporter).to have_received(:perform_async).with(SupportInterface::MonthlyStatisticsExports::ApplicationsByPrimarySpecialistSubjectExport, export_ids[7], {})
        expect(DataExporter).to have_received(:perform_async).with(SupportInterface::MonthlyStatisticsExports::ApplicationsBySecondarySubjectExport, export_ids[8], {})
        expect(DataExporter).to have_received(:perform_async).with(SupportInterface::MonthlyStatisticsExports::ApplicationsByProviderAreaExport, export_ids[9], {})
        expect(DataExporter).to have_received(:perform_async).with(SupportInterface::ExternalReportCandidatesExport, export_ids[10], {})
        expect(DataExporter).to have_received(:perform_async).with(SupportInterface::ExternalReportApplicationsExport, export_ids[11], {})
      end
    end

    context 'when the monthly statistics report should not be generated' do
      before do
        allow(DataExporter).to receive(:perform_async).and_return true
        allow(MonthlyStatisticsTimetable).to receive(:generate_monthly_statistics?).and_return false
      end

      it 'does not generate the monthly stats' do
        expect(MonthlyStatisticsReport.count).to eq(0)

        described_class.new.perform

        expect(MonthlyStatisticsReport.count).to eq(0)
      end

      it 'does not generate the monthly statistics exports' do
        described_class.new.perform

        expect(DataExporter).not_to have_received(:perform_async)
      end
    end
  end
end
