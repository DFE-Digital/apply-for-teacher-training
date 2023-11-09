require 'rails_helper'

RSpec.describe DfE::Bigquery::ApplicationMetrics do
  describe '.candidate_headline_statistics' do
    subject(:application_metrics) do
      described_class.candidate_headline_statistics(cycle_week: 11)
    end

    let(:client) { instance_double(Google::Cloud::Bigquery::Project) }
    let(:results) do
      [
        {
          number_of_candidates_submitted_to_date: 100,
          cycle_week: 11,
        },
      ]
    end

    before do
      allow(DfE::Bigquery).to receive(:client).and_return(client)
      allow(client).to receive(:query).and_return(results)
    end

    it 'instantiate an application metrics' do
      expect(application_metrics).to be_instance_of(described_class)
    end

    it 'assigns the attributes for the application metrics' do
      expect(application_metrics.number_of_candidates_submitted_to_date).to be 100
      expect(application_metrics.cycle_week).to be 11
    end
  end
end
