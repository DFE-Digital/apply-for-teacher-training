require 'rails_helper'

RSpec.describe CandidateMailers::SendWithdrawnOnRequestEmailWorker do
  describe '#perform' do
    before do
      mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(CandidateMailer).to receive(:application_withdrawn_on_request).and_return(mail)
    end

    it 'sends the application_withdrawn_on_request email to the candidate' do
      application_choice = create(:application_choice, status: :rejected)

      described_class.new.perform(application_choice.id)

      expect(CandidateMailer).to have_received(:application_withdrawn_on_request).with(application_choice)
    end
  end
end
