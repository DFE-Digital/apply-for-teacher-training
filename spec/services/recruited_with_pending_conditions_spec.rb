require 'rails_helper'

RSpec.describe RecruitedWithPendingConditions do
  let(:offer) { create(:offer) }

  subject(:service) { described_class.new(application_choice: offer.application_choice) }

  context 'when there is a pending SKE condition and other met conditions' do
    let(:offer) { create(:offer, :with_ske_conditions) }

    before do
      offer.conditions.reject { |condition| condition.is_a?(SkeCondition) }.each do |condition|
        condition.update!(status: :met)
      end
    end

    it 'returns false if the status is `pending_conditions`' do
      expect(service.call).to be(false)
    end

    it 'returns true if the status is `recruited`' do
      offer.application_choice.recruited!
      expect(service.call).to be(true)
    end
  end
end
