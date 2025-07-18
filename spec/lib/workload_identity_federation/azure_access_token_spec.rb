require 'rails_helper'

RSpec.describe WorkloadIdentityFederation::AzureAccessToken do
  subject(:client) { described_class.new }

  describe 'successful request' do
    before do
      stub_wif_config
      stub_azure_access_token
    end

    it 'calls the azure endpoint' do
      expect(client.call).to eq('fake_az_response_token')
    end
  end

  describe 'azure token file path not found' do
    before do
      stub_wif_config(azure_token_file_path: 'no/file/exists')
    end

    it 'raises an AzureTokenFilePathError' do
      expect { client.call }.to raise_error(WorkloadIdentityFederation::AzureTokenFilePathError).with_message('Azure token file could not be found')
    end
  end

  describe 'Azure responds unsuccessful' do
    before do
      stub_wif_config

      stub_request(:get, 'https://example.com')
      .to_return(
        status: 400,
        body: {
          'error' => 'unsupported_grant_type',
          'error_description' => 'AADSTS70003: The app requested an unsupported grant type ...',
          'error_codes' => [70_003],
          'timestamp' => '2024-03-18 19:55:40Z',
          'trace_id' => '0e58a943-a980-6d7e-89ba-c9740c572100',
          'correlation_id' => '84f1c2d2-5288-4879-a038-429c31193c9c',
        }.to_json,
        headers: {
          'content-type' => ['application/json; charset=utf-8'],
        },
      )
    end

    it 'raises an AzureAPIError' do
      expect { client.call }.to raise_error(WorkloadIdentityFederation::AzureAPIError)
        .with_message("\r\n\tstatus:\t400\r\n\tbody:\t{\"error\" => \"unsupported_grant_type\", \"error_description\" => \"AADSTS70003: The app requested an unsupported grant type ...\", \"error_codes\" => [70003], \"timestamp\" => \"2024-03-18 19:55:40Z\", \"trace_id\" => \"0e58a943-a980-6d7e-89ba-c9740c572100\", \"correlation_id\" => \"84f1c2d2-5288-4879-a038-429c31193c9c\"}")
    end
  end
end
