require 'rails_helper'

RSpec.describe OfferCondition do
  describe 'associations' do
    it '#application_choice returns the associated application choice' do
      offer_condition = create(:offer_condition, text: 'Provide evidence of degree qualification')

      expect(offer_condition.application_choice).not_to be_nil
    end
  end

  describe '#conditions_text' do
    it 'returns an array with the text of all the offer conditions' do
      conditions = build_list(:offer_condition, 4)
      offer = create(:offer, conditions: conditions)

      expect(offer.conditions_text).to eq(conditions.map(&:text))
    end
  end

  describe '#standard_condition?' do
    it 'returns true if the condition is part of the standard conditions' do
      condition = build(:offer_condition, text: 'Fitness to train to teach check')

      expect(condition.standard_condition?).to be true
    end

    it 'returns false if the condition is part of the standard conditions' do
      condition = build(:offer_condition, text: 'You must receive your deegree')

      expect(condition.standard_condition?).to be false
    end
  end
end
