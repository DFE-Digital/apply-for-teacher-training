require 'rails_helper'

RSpec.describe OfferCondition do
  describe 'associations' do
    it '#application_choice returns the associated application choice' do
      offer_condition = create(:offer_condition, text: 'Provide evidence of degree qualification')

      expect(offer_condition.application_choice).not_to be_nil
    end
  end
end
