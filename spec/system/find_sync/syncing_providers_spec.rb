require 'rails_helper'

RSpec.describe 'Syncing providers', sidekiq: true do
  include FindAPIHelper

  scenario 'Creates and updates providers' do
    given_there_are_2_providers_in_find
    and_one_of_the_providers_exists_already

    when_the_sync_runs
    then_it_creates_one_provider
    and_it_updates_another
    and_it_sets_the_last_synced_timestamp
  end

  def given_there_are_2_providers_in_find
    stub_find_api_all_providers_200([
      {
        provider_code: 'ABC',
        name: 'ABC College',
      },
      {
        provider_code: 'DEF',
        name: 'DER College',
      },
    ])
  end

  def and_one_of_the_providers_exists_already
    create(:provider, code: 'DEF', name: 'DEF College')
  end

  def when_the_sync_runs
    SyncAllFromFind.perform_async
  end

  def then_it_creates_one_provider
    expect(Provider.find_by(code: 'ABC')).not_to be_nil
  end

  def and_it_updates_another
    expect(Provider.find_by(code: 'DEF').name).to eql('DER College')
  end

  def and_it_sets_the_last_synced_timestamp
    expect(FindSyncCheck.last_sync).not_to be_blank
  end
end
