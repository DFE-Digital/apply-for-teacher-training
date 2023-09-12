require 'rails_helper'
RSpec.describe SaveOfferConditionsFromText do
  let(:conditions) { ['Test', 'Test but longer'] }
  let(:application_choice) { create(:application_choice) }

  describe 'initialize' do
    it 'discards blank conditions' do
      instance = described_class.new(application_choice: build(:application_choice), conditions: ['Dance', ''])

      expect(instance.conditions).to eq(['Dance'])
    end
  end

  describe '#save' do
    context 'when the application choice does not have an offer and there are empty conditions' do
      let(:conditions) { [] }

      it 'only creates an offer' do
        described_class.new(application_choice:, conditions:).save

        offer = Offer.find_by(application_choice:)
        expect(offer.conditions).to be_empty
      end
    end

    context 'when there is an offer with no conditions' do
      let(:application_choice) { create(:application_choice, :offered, offer: build(:unconditional_offer)) }

      it 'creates entries for all conditions' do
        described_class.new(application_choice:, conditions:).save

        offer = Offer.find_by(application_choice:)
        expect(offer.conditions.map(&:text)).to match_array(conditions)
      end
    end

    context 'when there is an existing offer with a condition', :with_audited do
      let(:conditions) { [build(:text_condition, description: 'Condition one')] }
      let(:application_choice) { create(:application_choice, :offered, offer: build(:offer, conditions:)) }

      context 'when there is only the existing condition' do
        it 'creates the new condition only' do
          expect {
            described_class.new(application_choice:, conditions: ['Condition one']).save
          }.not_to change(application_choice.associated_audits, :count)
        end
      end

      context 'when there is the existing and a new condition' do
        it 'creates the new condition only' do
          expect {
            described_class.new(application_choice:, conditions: ['Condition one', 'Condition two']).save
          }.to change(application_choice.associated_audits, :count).by(1)

          expect(application_choice.offer.all_conditions_text).to contain_exactly('Condition one', 'Condition two')
          expect(application_choice.associated_audits.last.action).to eq('create')
          expect(application_choice.associated_audits.last.audited_changes).to eq({
            status: 'pending',
            details: { 'description' => 'Condition two' },
            offer_id: application_choice.offer.id,
          }.stringify_keys)
        end
      end

      context 'when there are no conditions' do
        it 'removes all conditions' do
          expect {
            described_class.new(application_choice:, conditions: []).save
          }.to change(application_choice.associated_audits, :count).by(1)

          expect(application_choice.associated_audits.last.action).to eq('destroy')
          expect(application_choice.associated_audits.last.audited_changes).to eq({
            status: 'pending',
            details: { 'description' => 'Condition one' },
            offer_id: application_choice.offer.id,
          }.stringify_keys)
        end
      end

      context 'when there are edited conditions' do
        it 'removes them and adds new entries' do
          expect {
            described_class.new(application_choice:, conditions: ['Condition two']).save
          }.to change(application_choice.associated_audits, :count).by(2)

          expect(application_choice.offer.all_conditions_text).to contain_exactly('Condition two')

          audits = application_choice.associated_audits.last(2)
          expect(audits.first.action).to eq('destroy')
          expect(audits.first.audited_changes).to eq({
            status: 'pending',
            details: { 'description' => 'Condition one' },
            offer_id: application_choice.offer.id,
          }.stringify_keys)

          expect(audits.last.action).to eq('create')
          expect(audits.last.audited_changes).to eq({
            status: 'pending',
            details: { 'description' => 'Condition two' },
            offer_id: application_choice.offer.id,
          }.stringify_keys)
        end
      end
    end
  end
end
