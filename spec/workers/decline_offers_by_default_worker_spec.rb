require 'rails_helper'

RSpec.describe DeclineOffersByDefaultWorker do
  describe '#perform' do
    it 'declines all application choices returned by the query service' do
      offer_not_expired = create(:application_choice, status: 'offer', decline_by_default_at: 10.days.from_now)
      offer_expired = create(:application_choice, status: 'offer', decline_by_default_at: 1.day.ago)
      rejected = create(:application_choice, status: 'rejected', decline_by_default_at: 1.day.ago)

      described_class.new.perform

      expect(offer_not_expired.reload.status).to eq('offer')
      expect(offer_expired.reload.status).to eq('declined')
      expect(rejected.reload.status).to eq('rejected')
    end
  end
end
