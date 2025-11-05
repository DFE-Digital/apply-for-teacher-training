require 'rails_helper'

RSpec.describe ProviderInterface::DiversityReportExport do
  let(:provider) { create(:provider) }
  let(:diversity_data_by_provider) { instance_double(ProviderInterface::DiversityDataByProvider) }

  before do
    allow(ProviderInterface::DiversityDataByProvider).to receive(:new).with(provider: provider, recruitment_cycle_year: current_year).and_return(diversity_data_by_provider)
    allow(diversity_data_by_provider).to receive_messages(sex_data: [{ header: 'header', values: %w[1 2 3 4] }], disability_data: [{ header: 'header', values: %w[1 2 3 4] }], ethnicity_data: [{ header: 'header', values: %w[1 2 3 4] }], age_data: [{ header: 'header', values: %w[1 2 3 4] }])
  end

  describe '#call' do
    let(:export) { described_class.new(provider: provider, recruitment_cycle_year: current_year) }

    after do
      FileUtils.rm_rf(Rails.root.join("tmp/#{Time.zone.today}-xr-export").to_s)
    end

    it 'creates and returns a zip file containing CSV files' do
      Timecop.scale(100) do
        zip_file = export.call
        expect(zip_file).to be_a(String)
        expect(File.exist?(zip_file)).to be(true)

        %w[sex disability ethnicity age].each do |type|
          csv_filename = "#{type}_*.csv"
          expect(zip_file).to have_csv_files(csv_filename)

          csv_data = export.send("#{type}_export")
          expect(zip_file).to have_csv_file_content(csv_filename, csv_data)
        end
      end
    end
  end
end
