require 'rails_helper'

RSpec.describe ProviderInterface::ConfirmConditionsWizard do
  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:offer) {
    create(
      :offer,
      conditions: [
        create(:text_condition, status: :met, created_at: 3.seconds.ago),
        create(:text_condition, created_at: 2.seconds.ago),
        create(:ske_condition, created_at: 1.second.ago),
      ],
    )
  }
  let(:conditions) { offer.conditions }
  let(:statuses) { nil }

  let(:wizard) do
    described_class.new(
      store,
      offer:,
      statuses:,
    )
  end

  before { allow(store).to receive(:read) }

  describe 'validations' do
    let(:statuses) { { conditions.last.id.to_s => { 'status' => 'met' } } }

    it 'validates that all conditions have a status set' do
      expect(wizard).not_to be_valid
      expect(wizard.errors.first.message).to eq('Select a status')
    end
  end

  describe '#conditions' do
    context 'when built from an offer' do
      it 'returns the conditions of the offer without SKE conditions' do
        expect(wizard.conditions).to eq(conditions)
        expect(wizard.conditions.any? { |condition| condition.is_a?(SkeCondition) }).to be(true)
      end
    end

    context 'when built from status params' do
      let(:statuses) do
        conditions.to_h do |condition|
          [condition.id.to_s, { 'status' => %w[pending met unmet].sample }]
        end
      end

      it 'returns the conditions of the offer with modified statuses' do
        modified_conditions = wizard.conditions

        expect(modified_conditions.first.status).to eq(statuses[modified_conditions.first.id.to_s]['status'])
        expect(modified_conditions.last.status).to eq(statuses[modified_conditions.last.id.to_s]['status'])
      end

      context 'if unknown condition ids are given' do
        let(:statuses) do
          {
            'not_an_id' => { 'status' => 'unmet' },
            conditions.last.id.to_s => { 'status' => 'met' },
          }
        end

        it 'only modifies the statuses of the conditions in the offer' do
          modified_conditions = wizard.conditions

          expect(modified_conditions.first.status).to be_nil
          expect(modified_conditions.last.status).to eq('met')
        end
      end
    end
  end

  describe '#all_conditions_met?' do
    context 'all of the conditions are marked as met' do
      let(:statuses) do
        conditions.to_h do |condition|
          [condition.id.to_s, { 'status' => 'met' }]
        end
      end

      it 'returns true' do
        expect(wizard.all_conditions_met?).to be(true)
      end
    end

    context 'one of the conditions is not marked as met' do
      let(:statuses) do
        {
          conditions.first.id.to_s => { 'status' => 'pending' },
          conditions.last.id.to_s => { 'status' => 'met' },
        }
      end

      it 'returns false' do
        expect(wizard.all_conditions_met?).to be(false)
      end
    end
  end

  describe '#any_condition_not_met?' do
    context 'at least one of the conditions is marked as not met' do
      let(:statuses) do
        {
          conditions.first.id.to_s => { 'status' => %w[pending met unmet].sample },
          conditions.last.id.to_s => { 'status' => 'unmet' },
        }
      end

      it 'returns true' do
        expect(wizard.any_condition_not_met?).to be(true)
      end
    end

    context 'none of the conditions are marked as not met' do
      let(:statuses) do
        conditions.to_h do |condition|
          [condition.id.to_s, { 'status' => %w[pending met].sample }]
        end
      end

      it 'returns false' do
        expect(wizard.any_condition_not_met?).to be(false)
      end
    end
  end
end
