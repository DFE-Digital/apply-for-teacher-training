require 'rails_helper'

RSpec.describe CandidateMailers::SendWithdrawnLastApplicationChoiceEmailWorker do
  describe '#perform' do
    before do
      mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(CandidateMailer).to receive(:withdraw_last_application_choice).and_return(mail)
    end

    it 'sends the withdraw_last_application_choice email to the candidate' do
      application_form = create(:completed_application_form)
      create(:application_choice, status: :withdrawn, application_form: application_form)

      described_class.new.perform(application_form.id)

      expect(CandidateMailer).to have_received(:withdraw_last_application_choice).with(application_form)
    end
  end
end
