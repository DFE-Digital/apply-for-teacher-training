require 'rails_helper'

RSpec.describe DfE::Bigquery do
  before do
    stub_azure_access_token
    stub_token_exchange
    stub_google_access_token
    stub_wif_config
  end

  describe '#client' do
    context 'when missing configuration' do
      it 'raises a configuration error' do
        config = Struct.new(:bigquery_retries,
                            :bigquery_timeout,
                            :bigquery_project_id).new(1, 2, nil)
        allow(described_class).to receive(:config).and_return(config)
        expect { described_class.client }.to raise_error(DfE::Bigquery::ConfigurationError)
      end
    end

    context 'when valid configuration' do
      let(:bigquery) { Google::Apis::BigqueryV2::BigqueryService.new }

      it 'instantiates bigquery object' do
        allow(Google::Apis::BigqueryV2::BigqueryService).to receive(:new).and_return(bigquery)
        expect(described_class.client).to eq(bigquery)
      end
    end
  end
end
