require 'rails_helper'

RSpec.describe CandidateMailers::SendWithdrawnOfferEmailWorker do
  describe '#perform' do
    before do
      mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(CandidateMailer).to receive(:offer_withdrawn).and_return(mail)
    end

    it 'sends the offer_withdrawn email to the candidate' do
      application_choice = create(:application_choice, status: :withdrawn)

      described_class.new.perform(application_choice.id)

      expect(CandidateMailer).to have_received(:offer_withdrawn).with(application_choice)
    end
  end
end
