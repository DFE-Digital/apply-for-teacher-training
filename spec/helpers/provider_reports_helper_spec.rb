require 'rails_helper'

RSpec.describe ProviderReportsHelper do
  describe '#mid_cycle_report_present_for?' do
    let(:provider) { create(:provider) }

    context 'when a report exists' do
      before { create(:provider_mid_cycle_report, provider: provider) }

      it 'returns true' do
        expect(mid_cycle_report_present_for?(provider)).to be(true)
      end
    end

    context 'when there is no report' do
      it 'returns false' do
        expect(mid_cycle_report_present_for?(provider)).to be(false)
      end
    end
  end

  describe '#mid_cycle_report_label_for' do
    let(:provider) { create(:provider) }

    context 'when a report exists' do
      before do
        create(
          :provider_mid_cycle_report,
          provider: provider,
          publication_date: Date.new(2022, 7, 1),
        )
      end

      it 'returns correct label' do
        expect(mid_cycle_report_label_for(provider)).to eq('2021 to 2022 recruitment cycle performance')
      end
    end

    context 'when there is no report' do
      it 'returns empty string' do
        expect(mid_cycle_report_label_for(provider)).to eq('')
      end
    end
  end
end
