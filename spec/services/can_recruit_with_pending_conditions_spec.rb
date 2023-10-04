require 'rails_helper'

RSpec.describe CanRecruitWithPendingConditions do
  let(:offer) { create(:offer) }
  subject(:service) { described_class.new(application_choice: offer.application_choice) }

  context 'when feature flag is off' do
    let(:offer) { create(:offer, :with_ske_conditions) }

    before do
      FeatureFlag.deactivate(:recruit_with_pending_conditions)
      offer.conditions.select { |condition| !condition.is_a?(SkeCondition) }.each do |condition|
        condition.update!(status: :met)
      end
    end

    it 'returns false' do
      expect(service.call).to be(false)
    end 
  end

  context 'when feature flag is on' do
    before { FeatureFlag.activate(:recruit_with_pending_conditions) }

    context 'when there are various pending conditions' do
      let(:offer) { create(:offer, :with_unmet_conditions) }

      it 'returns false' do
        expect(service.call).to be(false)
      end 
    end

    context 'when there is a pending SKE condition and other met conditions' do
      let(:offer) { create(:offer, :with_ske_conditions) }

      before do
        offer.conditions.select { |condition| !condition.is_a?(SkeCondition) }.each do |condition|
          condition.update!(status: :met)
        end
      end

      it 'returns true' do
        expect(service.call).to be(true)
      end 
    end
  end
end
