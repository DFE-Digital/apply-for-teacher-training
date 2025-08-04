require 'rails_helper'

RSpec.describe CandidateMailers::SendDeclinedLastApplicationChoiceEmailWorker do
  describe '#perform' do
    before do
      mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(CandidateMailer).to receive(:decline_last_application_choice).and_return(mail)
    end

    it 'sends the decline_last_application_choice email to the candidate' do
      application_choice = create(:application_choice, status: :rejected)

      described_class.new.perform(application_choice.id)

      expect(CandidateMailer).to have_received(:decline_last_application_choice).with(application_choice)
    end
  end
end
