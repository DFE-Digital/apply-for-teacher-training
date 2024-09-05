require 'rails_helper'

RSpec.describe WarmCache do
  include VendorAPISpecHelpers
  before do
    @application_choice = create_application_choice_for_currently_authenticated_provider
    api_token
    create(:vendor_api_request, provider: currently_authenticated_provider, request_path: '/api/v1.1/applications')
  end

  describe '#call' do
    it 'caches all relevant application choices' do
      token = currently_authenticated_provider.vendor_api_tokens.last
      token.update(last_used_at: 1.week.ago)
      @application_choice.update(updated_at: Time.zone.local(2024, 9, 4, 14, 0))
      expect(described_class.new.call).to eq(currently_authenticated_provider.name => [@application_choice.id])
    end
  end
end
