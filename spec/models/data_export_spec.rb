require 'rails_helper'

RSpec.describe DataExport, type: :model do
  describe '#can_generate_export?' do
    before do
      allow(MonthlyStatisticsTimetable).to receive(:latest_report_date).and_return(Date.yesterday)
    end

    it 'returns true if the export is not in the MONTHLY_STATISTICS_EXPORTS constant' do
      (described_class.export_types.values - described_class::MONTHLY_STATISTICS_EXPORTS).each do |export_type|
        create(:data_export, export_type: export_type)

        expect(described_class.can_generate_export?(export_type)).to eq true
      end
    end

    it 'returns true if no exports have been generated since the latest monthly report generation date' do
      described_class::MONTHLY_STATISTICS_EXPORTS.each do |export_type|
        expect(described_class.can_generate_export?(export_type)).to eq true
      end
    end

    it 'returns false if an export has been generated since the latest monthly report generation date' do
      described_class::MONTHLY_STATISTICS_EXPORTS.each do |export_type|
        create(:data_export, export_type: export_type)
        expect(described_class.can_generate_export?(export_type)).to eq false
      end
    end
  end
end
