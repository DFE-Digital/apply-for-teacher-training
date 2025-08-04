require 'rails_helper'

RSpec.describe CandidateMailers::SendRejectionEmailWorker do
  describe '#perform' do
    before do
      mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(CandidateMailer).to receive(:application_rejected).and_return(mail)
    end

    it 'sends the application_rejected email to the candidate' do
      application_choice = create(:application_choice, status: :rejected)

      described_class.new.perform(application_choice.id)

      expect(CandidateMailer).to have_received(:application_rejected).with(application_choice)
    end
  end
end
