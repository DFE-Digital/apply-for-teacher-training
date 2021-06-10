require 'rails_helper'
RSpec.describe UpdateOfferConditions do
  let(:conditions) { ['Test', 'Test but longer'] }
  let(:application_choice) { create(:application_choice) }

  describe '#call' do
    it 'writes the conditions to the offer conditions model' do
      described_class.new(application_choice: application_choice, conditions: conditions).call

      offer = Offer.find_by(application_choice: application_choice)
      expect(offer.conditions.count).to eq(2)
      expect(offer.conditions.first.text).to eq('Test')
      expect(offer.conditions.last.text).to eq('Test but longer')
    end

    context 'when the application choice has an offer with no conditions' do
      let(:conditions) { nil }

      it 'does not create any offer conditions' do
        described_class.new(application_choice: application_choice, conditions: conditions).call

        offer = Offer.find_by(application_choice: application_choice)
        expect(offer.conditions).to be_empty
      end
    end

    context 'when the application choice is in the recruited state' do
      let(:application_choice) { create(:application_choice, :with_offer, status: :recruited) }

      it 'creates new conditions in the met state' do
        described_class.new(application_choice: application_choice).call

        offer = Offer.find_by(application_choice: application_choice)
        expect(offer.conditions.map(&:status).uniq).to contain_exactly('met')
      end
    end

    context 'when the application choice is in the conditions_not_met state' do
      let(:application_choice) { create(:application_choice, :with_offer, status: :conditions_not_met) }

      it 'creates new conditions in the unmet state' do
        described_class.new(application_choice: application_choice).call

        offer = Offer.find_by(application_choice: application_choice)
        expect(offer.conditions.map(&:status).uniq).to contain_exactly('unmet')
      end
    end

    context 'when there is an existing offer' do
      let(:conditions) { [build(:offer_condition, text: 'Evidence of being cool')] }
      let(:application_choice) { create(:application_choice, :with_offer, offer: build(:offer, conditions: conditions)) }

      it 'overwrites the existing offer conditions' do
        offer = Offer.find_by(application_choice: application_choice)
        expect(offer.conditions.count).to eq(1)
        expect(offer.conditions.first.text).to eq('Evidence of being cool')

        described_class.new(application_choice: application_choice, conditions: ['Test', 'Test but longer']).call

        offer = Offer.find_by(application_choice: application_choice)
        expect(offer.conditions.count).to eq(2)
        expect(offer.conditions.first.text).to eq('Test')
        expect(offer.conditions.last.text).to eq('Test but longer')
      end
    end
  end
end
