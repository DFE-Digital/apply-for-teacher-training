require 'rails_helper'

RSpec.describe FormatResidencyDetailsService do
  describe '#residency_details_value' do
    context 'when the immigration status is eu_settled' do
      let(:application_form) { build(:application_form, immigration_status: 'eu_settled') }

      it 'returns eu settled' do
        expect(described_class.new(application_form: application_form).residency_details_value).to eq('EU settled status')
      end
    end

    context 'when the immigration status is pre eu_settled' do
      let(:application_form) { build(:application_form, immigration_status: 'eu_pre_settled') }

      it 'returns pre eu settled' do
        expect(described_class.new(application_form: application_form).residency_details_value).to eq('EU pre-settled status')
      end
    end

    context 'when the immigration status is other' do
      let(:application_form) { build(:application_form, immigration_status: 'other', right_to_work_or_study_details: 'i am allowed') }

      it 'returns pre eu settled' do
        expect(described_class.new(application_form: application_form).residency_details_value).to eq('i am allowed')
      end
    end
  end
end
