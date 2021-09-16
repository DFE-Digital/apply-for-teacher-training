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
      failed_recently = create(:provider, name: 'failed', provider_type: 'university')
      synced_1w_ago = create(:provider, name: '1 week ago', provider_type: 'university')
      synced_2d_ago = create(:provider, name: '3 hours', provider_type: 'university')

      create(:vendor_api_request, provider: synced_recently)
      create(:vendor_api_request, provider: failed_recently, status_code: 422)
      create(:vendor_api_request, provider: synced_1w_ago, created_at: 1.week.ago)
      create(:vendor_api_request, provider: synced_2d_ago, created_at: 2.days.ago)

      expect(monitor.no_sync_in_24h.map(&:id)).to eq [failed_recently.id, synced_2d_ago.id, synced_1w_ago.id]
    end
  end

  describe '#no_decisions_in_7d' do
    it 'returns only providers who have connected and who have not made decisions in 7 days' do
      _never_connected = create(:provider, name: 'never', provider_type: 'university')
      decided_recently = create(:provider, name: 'recently', provider_type: 'university')
      failed_recently = create(:provider, name: 'failed', provider_type: 'university')
      decided_over_2w_ago = create(:provider, name: '2 weeks', provider_type: 'university')
      decided_over_7d_ago = create(:provider, name: '7 days', provider_type: 'university')

      create(:vendor_api_request, request_method: 'POST', provider: decided_recently)
      create(:vendor_api_request, request_method: 'POST', provider: failed_recently, status_code: 422)
      create(:vendor_api_request, request_method: 'POST', provider: decided_over_7d_ago, created_at: 8.days.ago)
      create(:vendor_api_request, request_method: 'POST', provider: decided_over_2w_ago, created_at: 15.days.ago)

      expect(monitor.no_decisions_in_7d.map(&:id)).to eq [failed_recently.id, decided_over_7d_ago.id, decided_over_2w_ago.id]
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

      expect(monitor.providers_with_errors.size).to eq 1
      expect(monitor.providers_with_errors.first.id).to eq errored_recently.id
      expect(monitor.providers_with_errors.first.error_count).to be 1
      expect(monitor.providers_with_errors.first.request_count).to be 2
      expect(monitor.providers_with_errors.first.error_rate).to eq 50.0
    end
  end
end
