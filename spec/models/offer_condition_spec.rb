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
end
