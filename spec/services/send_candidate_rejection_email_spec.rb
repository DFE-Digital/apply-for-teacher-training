require 'rails_helper'

RSpec.describe SendCandidateRejectionEmail do
  describe '#call' do
    let(:application_form) { build(:completed_application_form) }
    let(:application_choice) { create(:application_choice, status: :rejected, application_form:) }
    let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    context 'when an application is rejected' do
      before do
        allow(CandidateMailer).to receive(:application_rejected).and_return(mail)
        described_class.new(application_choice:).call
      end

      it 'the applications_rejected email is sent to the candidate' do
        expect(CandidateMailer).to have_received(:application_rejected).with(application_choice)
      end
    end
  end
end
