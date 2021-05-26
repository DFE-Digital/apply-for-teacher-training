require 'rails_helper'

RSpec.describe Offer do
  describe 'associations' do
    it '#conditions returns the list of conditions' do
      condition1 = create(:offer_condition, text: 'Provide evidence of degree qualification')
      condition2 = create(:offer_condition, text: 'Do a backflip and send us a video')
      offer = create(:offer, conditions: [condition1, condition2])

      expect(offer.conditions.map(&:text)).to contain_exactly('Provide evidence of degree qualification', 'Do a backflip and send us a video')
    end
  end

  describe '#unconditional' do
    it 'returns true when there are no conditions' do
      offer = create(:unconditional_offer)

      expect(offer.unconditional?).to be true
    end
  end
end
