require 'rails_helper'

RSpec.describe OfferCondition do
  describe 'associations' do
    it '#application_choice returns the associated application choice' do
      text_condition = create(:text_condition, description: 'Provide evidence of degree qualification')

      expect(text_condition.application_choice).not_to be_nil
    end
  end

  describe 'touching' do
    before do
      TestSuiteTimeMachine.unfreeze!
    end

    it 'changes the updated at timestamp on the offer' do
      text_condition = create(:text_condition, description: 'Provide evidence of degree qualification')
      expect { text_condition.update(text: 'different time') }
        .to(change { text_condition.offer.application_choice.updated_at })
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:status) }
  end

  describe '#conditions_text' do
    it 'returns an array with the text of all the offer conditions' do
      conditions = build_list(:text_condition, 4)
      offer = create(:offer, conditions:)

      expect(offer.conditions_text).to eq(conditions.map(&:text))
    end
  end

  describe '#standard_condition?' do
    it 'returns true if the condition is part of the standard conditions' do
      condition = build(:text_condition, description: 'Fitness to train to teach check')

      expect(condition.standard_condition?).to be true
    end

    it 'returns false if the condition is part of the standard conditions' do
      condition = build(:text_condition, description: 'You must receive your deegree')

      expect(condition.standard_condition?).to be false
    end
  end
end
