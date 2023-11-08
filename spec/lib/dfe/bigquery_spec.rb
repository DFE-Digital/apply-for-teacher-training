require 'rails_helper'

RSpec.describe DfE::Bigquery do
  describe '#client' do
    context 'when missing configuration' do
      it 'raises a configuration error' do
        with_config(bigquery_project_id: nil) do
          expect { described_class.client }.to raise_error(DfE::Bigquery::ConfigurationError)
        end
      end
    end

    context 'when valid configuration' do
      let(:bigquery) { instance_double(Google::Cloud::Bigquery) }

      it 'instantiates bigquery object' do
        with_config(bigquery_project_id: 'some-project', bigquery_api_json_key: '{}', bigquery_retries: 2, bigquery_timeout: 10) do
          allow(Google::Cloud::Bigquery).to receive(:new).and_return(bigquery)
          expect(described_class.client).to eq(bigquery)
        end
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
