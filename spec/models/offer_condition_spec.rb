require 'rails_helper'

RSpec.describe OfferCondition do
  describe 'associations' do
    it '#application_choice returns the associated application choice' do
      offer_condition = create(:offer_condition, text: 'Provide evidence of degree qualification')

      expect(offer_condition.application_choice).not_to be_nil
    end
  end

  describe 'auditing', with_audited: true do
    it 'audits changes to the model' do
      offer_condition = create(:offer_condition, text: 'Provide evidence of degree qualification')

      offer_condition.update!(status: 'met')

      expect(offer_condition.audits.last.audited_changes).to eq({ 'status' => %w[pending met] })
    end

    it 'associates audits to the application choice' do
      offer_condition = create(:offer_condition, text: 'Provide evidence of degree qualification')

      expect(offer_condition.audits.last.associated_type).to eq('ApplicationChoice')
      expect(offer_condition.audits.last.associated_id).to eq(offer_condition.application_choice.id)
    end
  end
end
