require 'rails_helper'

RSpec.describe CanRecruitWithPendingConditions do
  let(:offer) { create(:offer) }

  subject(:service) { described_class.new(application_choice: offer.application_choice) }

  context 'when there is a pending SKE condition and other met conditions' do
    let(:offer) { create(:offer, :with_ske_conditions) }
    let(:provider_type) { :scitt }

    before do
      offer.conditions.reject { |condition| condition.is_a?(SkeCondition) }.each do |condition|
        condition.update!(status: :met)
      end
      offer.application_choice.provider.update(provider_type: provider_type)
      offer.application_choice.course.update(start_date: 2.months.from_now)
    end

    context 'when the provider is a SCITT and the course start date is within 3 months' do
      it 'returns true' do
        expect(service.call).to be(true)
      end
    end

    context 'when the provider is a lead school and accredited body is a SCITT' do
      let(:accredited_provider) { create(:provider, :scitt) }

      before do
        offer.application_choice.course.update(accredited_provider: accredited_provider)
      end

      it 'returns true' do
        expect(service.call).to be(true)
      end
    end

    context 'when the application choice is already `recruited`' do
      before do
        offer.application_choice.recruited!
      end

      it 'returns false if the status is already `recruited`' do
        expect(service.call).to be(false)
      end
    end

    context 'when the provider is NOT a SCITT and the course start date is within 3 months' do
      let(:hei_provider) { create(:provider, :university) }

      before do
        offer.application_choice.provider.update(provider_type: :university)
        offer.application_choice.course.update(accredited_provider: hei_provider)
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
