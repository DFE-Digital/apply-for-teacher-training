require 'rails_helper'

RSpec.describe UCASMatches::SendUCASMatchInitialEmailsMultipleAcceptances do
  describe '#call' do
    let(:candidate) { create(:candidate) }
    let(:ucas_match) { create(:ucas_match, :with_multiple_acceptances) }
    let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    context 'when the application has been accepted on both apply and ucas' do
      describe 'when initial emails have not been sent' do
        let(:ucas_match) { create(:ucas_match, action_taken: 'initial_emails_sent', candidate: candidate) }

        it 'when the emails have already been sent it throws an exception' do
          expect { described_class.new(ucas_match).call }.to raise_error("Initial emails for UCAS match ##{ucas_match.id} were already sent")
        end
      end

      describe 'when the initial emails have not been sent already' do
        before do
          allow(CandidateMailer).to receive(:ucas_match_initial_email_multiple_acceptances).and_return(mail)
          described_class.new(ucas_match).call
        end

        it 'sends the candidate the initial ucas_match email for multiple acceptances' do
          expect(CandidateMailer).to have_received(:ucas_match_initial_email_multiple_acceptances).with(ucas_match.candidate)
        end
      end
    end
  end
end
