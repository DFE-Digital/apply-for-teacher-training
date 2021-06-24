require 'rails_helper'

RSpec.describe DataMigrations::FixEmptyOfferConditions do
  describe '#change' do
    let(:pending_application) { create(:application_choice, :with_accepted_offer) }
    let(:offer) { create(:offer, application_choice: create(:application_choice, :with_accepted_offer)) }

    before do
      create(:offer, application_choice: pending_application, conditions: [create(:offer_condition, text: '')])
    end

    it 'destroys to the empty OfferCondition' do
      expect {
        described_class.new.change
      }.to change(OfferCondition, :count).by(-1)
    end

    it 'updates applications with empty conditions pending to recruited state' do
      described_class.new.change

      expect(pending_application.reload).to be_recruited
    end

    it 'ignores applications with empty and non empty conditions pending' do
      create(:offer_condition, text: '5 pressups', offer: offer)
      create(:offer_condition, text: '', offer: offer)

      described_class.new.change

      expect(offer.application_choice.reload).to be_pending_conditions
    end

    it 'ignores offer conditions with text' do
      create(:offer_condition, text: '5 pressups', offer: offer)

      described_class.new.change

      expect(OfferCondition.where.not(text: '')).not_to be_empty
    end
  end
end
