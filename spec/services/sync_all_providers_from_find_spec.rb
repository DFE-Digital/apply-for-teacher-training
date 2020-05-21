require 'rails_helper'

RSpec.describe SyncAllProvidersFromFind do
  include FindAPIHelper

  describe 'ingesting providers' do
    it 'correctly creates all the providers when the database is empty' do
      stub_find_api_all_providers_200([
        {
          provider_code: 'ABC',
          name: 'ABC College',
        },
        {
          provider_code: 'DEF',
          name: 'DEF College',
        },
      ])

      expect { SyncAllProvidersFromFind.call }.to change { Provider.count }.by(2)
    end

    it 'sets the last updated timestamp' do
      FindSyncCheck.clear_last_sync

      stub_find_api_all_providers_200([
        {
          provider_code: 'ABC',
          name: 'ABC College',
        },
      ])

      SyncAllProvidersFromFind.call

      expect(FindSyncCheck.last_sync).not_to be_blank
    end

    it 'does not set the last updated timestamp when encountering an error' do
      FindSyncCheck.clear_last_sync

      stub_find_api_all_providers_503

      expect { SyncAllProvidersFromFind.call }.to raise_error(SyncAllProvidersFromFind::SyncFindApiError)

      expect(FindSyncCheck.last_sync).to be_blank
    end

    it 'creates only missing providers when the database contains some of the providers already' do
      create :provider, code: 'DEF', name: 'DEF College'

      stub_find_api_all_providers_200([
        {
          provider_code: 'ABC',
          name: 'ABC College',
        },
        {
          provider_code: 'DEF',
          name: 'DEF College',
        },
      ])

      expect { SyncAllProvidersFromFind.call }.to change { Provider.count }.by(1)
    end

    it 'updates the name of existing providers' do
      existing_provider = create :provider, code: 'DEF', name: 'DER College'

      stub_find_api_all_providers_200([
        {
          provider_code: 'ABC',
          name: 'ABC College',
        },
        {
          provider_code: 'DEF',
          name: 'DEF College',
        },
      ])

      SyncAllProvidersFromFind.call
      expect(existing_provider.reload.name).to eq 'DEF College'
    end
  end
end
