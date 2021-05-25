require 'rails_helper'
RSpec.describe UpdateOfferConditions do
  let(:conditions) { ['Test', 'Test but longer'] }
  let(:application_choice) { create(:application_choice, offer: { conditions: conditions }) }

  describe '#call' do
    it 'writes the conditions to the offer conditions model' do
      described_class.new(application_choice: application_choice).call
      offer = Offer.find_by(application_choice: application_choice)
      expect(offer.conditions.count).to eq(2)
      expect(offer.conditions.first.text).to eq('Test')
      expect(offer.conditions.last.text).to eq('Test but longer')
    end

    context 'when there is an existing offer' do
      let!(:existing_offer) { create(:offer, application_choice: application_choice) }

      it 'overwrites the existing offer' do
        offer = Offer.find_by(application_choice: application_choice)
        expect(offer.conditions.count).to eq(1)
        expect(offer.conditions.first.text).to eq('Evidence of being cool')
        described_class.new(application_choice: application_choice).call
        offer = Offer.find_by(application_choice: application_choice)
        expect(offer.conditions.count).to eq(2)
        expect(offer.conditions.first.text).to eq('Test')
        expect(offer.conditions.last.text).to eq('Test but longer')
      end
    end
  end
end
