require 'rails_helper'

RSpec.describe RejectionReasons::RejectionReasonComponent do
  context 'when application is offer withdrawn' do
    let(:offer_withdrawal_reason) { 'I am withdrawing the offer because of X, Y and Z' }

    it 'renders withdrawn reason' do
      application_choice = create(:application_choice, :with_withdrawn_offer, offer_withdrawal_reason: offer_withdrawal_reason)
      result = render_inline(described_class.new(application_choice: application_choice))
      expect(result.text.chomp).to eq(offer_withdrawal_reason)
    end
  end

  context 'when application is rejected' do
    let(:rejection_reason) { 'The course became full' }

    it 'renders rejection reason' do
      application_choice = create(:application_choice, :with_rejection, rejection_reason: rejection_reason)
      result = render_inline(described_class.new(application_choice: application_choice))

      expect(result.text.chomp).to eq(rejection_reason)
    end
  end
end
