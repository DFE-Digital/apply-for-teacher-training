require 'rails_helper'

RSpec.describe Azure::AccessToken do
  subject(:client) { described_class.new }

  describe 'successful request' do
    before do
      Azure.configure do |c|
        c.google_cloud_credentials = { credential_source: { url: 'https://example.com' } }
        c.azure_client_id = 'fake_az_client_id_1234'
        c.azure_scope = 'fake_az_scope'
        c.azure_token_file_path = 'fake_az_token_path'
      end

      stub_request(:get, 'https://example.com')
      .to_return(
        status: 200,
        body: {
          'token_type' => 'Bearer',
          'expires_in' => 86_399,
          'ext_expires_in' => 86_399,
          'access_token' => 'fake_az_response_token',
        }.to_json,
        headers: {
          'content-type' => ['application/json; charset=utf-8'],
        },
      )
      allow(File).to receive(:read).and_return('asdf')
    end

    it 'calls the azure endpoint' do
      expect(client.call).to eq('fake_az_response_token')
    end
  end

  describe 'azure token file path not found' do
    before do
      Azure.configure do |c|
        c.google_cloud_credentials = { credential_source: { url: 'https://example.com' } }
        c.azure_client_id = 'fake_az_client_id_1234'
        c.azure_scope = 'fake_az_scope'
        c.azure_token_file_path = 'fake_az_token_path'
      end
    end

    it 'raises an AzureTokenFilePathError' do
      expect { client.call }.to raise_error(Azure::AzureTokenFilePathError)
    end
  end

  describe 'Azure responds unsuccessful' do
    before do
      Azure.configure do |c|
        c.google_cloud_credentials = { credential_source: { url: 'https://example.com' } }
        c.azure_client_id = 'fake_az_client_id_1234'
        c.azure_scope = 'fake_az_scope'
        c.azure_token_file_path = 'fake_az_token_path'
      end

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
      allow(File).to receive(:read).and_return('asdf')
    end

    it 'raises an AzureAPIError' do
      expect { client.call }.to raise_error(Azure::AzureAPIError)
    end
  end
end
