require 'rails_helper'

RSpec.describe DfE::Bigquery do
  before do
    stub_azure_access_token
    stub_token_exchange
    stub_google_access_token
    stub_azure_config
  end

  describe '#client' do
    context 'when missing configuration' do
      it 'raises a configuration error' do
        with_config(bigquery_project_id: nil) do
          expect { described_class.client }.to raise_error(DfE::Bigquery::ConfigurationError)
        end
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

  def with_config(options)
    old_config = DfE::Bigquery.config.dup
    DfE::Bigquery.instance_variable_set(:@client, nil)

    DfE::Bigquery.configure do |config|
      options.each { |option, value| config[option] = value }
    end

    yield
  ensure
    DfE::Bigquery.instance_variable_set(:@config, old_config)
  end
end
