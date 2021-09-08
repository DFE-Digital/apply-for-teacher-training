require 'rails_helper'

RSpec.describe SupportInterface::VendorAPIMonitor do
  subject(:monitor) do
    described_class.new
  end

  describe '#never_connected' do
    it 'returns only providers with no API request logs ever' do
      provider_who_hasnt_connected = create(:provider, provider_type: 'university')
      provider_who_has_connected = create(:provider, provider_type: 'university')

      create(:vendor_api_request, provider: provider_who_has_connected)

      expect(monitor.never_connected).to match_array [provider_who_hasnt_connected]
    end
  end

  describe '#no_sync_in_24h' do
    it 'returns only providers who have connected and who have not synced in 24h' do
      _never_connected = create(:provider, name: 'never', provider_type: 'university')
      synced_recently = create(:provider, name: 'recently', provider_type: 'university')
      synced_over_24h_ago = create(:provider, name: 'stale', provider_type: 'university')

      create(:vendor_api_request, provider: synced_recently)
      create(:vendor_api_request, provider: synced_over_24h_ago, created_at: 2.days.ago)

      expect(monitor.no_sync_in_24h.count).to eq 1
      expect(monitor.no_sync_in_24h.first.id).to eq synced_over_24h_ago.id
    end
  end

  describe '#no_decisions_in_7d' do
    it 'returns only providers who have connected and who have not synced in 7 days' do
      _never_connected = create(:provider, name: 'never', provider_type: 'university')
      decided_recently = create(:provider, name: 'recently', provider_type: 'university')
      decided_over_7d_ago = create(:provider, name: 'stale', provider_type: 'university')

      create(:vendor_api_request, request_method: 'POST', provider: decided_recently)
      create(:vendor_api_request, request_method: 'POST', provider: decided_over_7d_ago, created_at: 8.days.ago)

      expect(monitor.no_decisions_in_7d.count).to eq 1
      expect(monitor.no_decisions_in_7d.first.id).to eq decided_over_7d_ago.id
    end
  end

  describe '#providers_with_errors' do
    it 'returns structs with providers who have connected and who have caused errors in the last 7 days' do
      _never_connected = create(:provider, name: 'never', provider_type: 'university')
      errored_recently = create(:provider, name: 'recently', provider_type: 'university')
      errored_over_7d_ago = create(:provider, name: 'stale', provider_type: 'university')
      no_errors = create(:provider, name: 'no-errors', provider_type: 'university')

      create(:vendor_api_request, request_method: 'POST', status_code: 422, provider: errored_recently)
      create(:vendor_api_request, request_method: 'POST', status_code: 200, provider: errored_recently)
      create(:vendor_api_request, request_method: 'POST', status_code: 200, provider: no_errors)

      create(:vendor_api_request, request_method: 'POST', status_code: 422, provider: errored_over_7d_ago, created_at: 8.days.ago)

      expect(monitor.providers_with_errors.count).to eq 1
      expect(monitor.providers_with_errors.first.id).to eq errored_recently.id
      expect(monitor.providers_with_errors.first.error_count).to be 1
      expect(monitor.providers_with_errors.first.request_count).to be 2
      expect(monitor.providers_with_errors.first.error_rate).to eq '50.0%'
    end
  end
end
