require 'rails_helper'

RSpec.describe CanRecruitWithPendingConditions do
  let(:offer) { create(:offer) }

  subject(:service) { described_class.new(application_choice: offer.application_choice) }

  context 'when feature flag is off' do
    let(:offer) { create(:offer, :with_ske_conditions) }

    before do
      FeatureFlag.deactivate(:recruit_with_pending_conditions)
      offer.conditions.reject { |condition| condition.is_a?(SkeCondition) }.each do |condition|
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
        offer.conditions.reject { |condition| condition.is_a?(SkeCondition) }.each do |condition|
          condition.update!(status: :met)
        end
        offer.application_choice.provider.update(provider_type: :scitt)
        offer.application_choice.course.update(start_date: 2.months.from_now)
      end

      context 'when the provider is a SCITT and the course start date is within 3 months' do
        it 'returns true' do
          expect(service.call).to be(true)
        end
      end

      context 'when the provider is NOT a SCITT and the course start date is within 3 months' do
        before do
          offer.application_choice.provider.update(provider_type: :university)
        end

        it 'returns false' do
          expect(service.call).to be(false)
        end
      end

      context 'when the provider is a SCITT and the course start date is NOT within 3 months' do
        before do
          offer.application_choice.course.update(start_date: 4.months.from_now)
        end

        it 'returns false' do
          expect(service.call).to be(false)
        end
      end
    end
  end
end
