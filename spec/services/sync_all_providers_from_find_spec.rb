require 'rails_helper'

RSpec.describe SyncAllProvidersFromFind do
  include FindAPIHelper

  describe 'ingesting providers' do
    it 'correctly creates all the entities' do
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
  end
end
