require 'rails_helper'

RSpec.describe CSVNameHelper, type: :helper do
  around do |example|
    Timecop.freeze(2020, 6, 1, 12) do
      example.run
    end
  end

  let(:export_name) { 'extremely-cool-data' }
  let(:cycle_years) { [0, 2000] }
  let(:providers) { [create(:provider, name: 'Mars University')] }

  describe '#csv_filename' do
    context 'a report based on a single provider' do
      it 'returns a string with the provider name' do
        result = csv_filename(export_name: export_name, cycle_years: cycle_years, providers: providers)
        expect(result).to eq('extremely-cool-data_1999-to-2000_mars-university_2020-06-01_12-00-00.csv')
      end
    end

    context 'a report based on a multiple providers' do
      let(:providers) { create_list(:provider, 3) }

      it 'returns a string with multiple providers' do
        result = csv_filename(export_name: export_name, cycle_years: cycle_years, providers: providers)
        expect(result).to eq('extremely-cool-data_1999-to-2000_multiple-providers_2020-06-01_12-00-00.csv')
      end
    end

    context 'a report spanning multiple recruitment cycles' do
      let(:cycle_years) { [2000, 2005] }

      it 'returns a string with the full range of years' do
        result = csv_filename(export_name: export_name, cycle_years: cycle_years, providers: providers)
        expect(result).to eq('extremely-cool-data_1999-to-2005_mars-university_2020-06-01_12-00-00.csv')
      end
    end
  end
end
