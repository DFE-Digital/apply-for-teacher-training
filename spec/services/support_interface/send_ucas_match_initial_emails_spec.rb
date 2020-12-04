require 'rails_helper'

RSpec.describe SupportInterface::SendUCASMatchInitialEmails do
  describe '#call' do
    let(:ucas_match) { create(:ucas_match) }
    let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }
    let(:multiple_acceptances_mailer) { instance_double(SupportInterface::SendUCASMatchInitialEmailsMultipleAcceptances, call: true) }
    let(:duplicate_applications_mailer) { instance_double(SupportInterface::SendUCASMatchInitialEmailsDuplicateApplications, call: true) }

    context 'when the application has been accepted on both UCAS and Apply' do
      before do
        allow(ucas_match).to receive(:application_accepted_on_ucas_and_accepted_on_apply?).and_return(true)
        allow(SupportInterface::SendUCASMatchInitialEmailsMultipleAcceptances).to receive(:new).with(ucas_match).and_return(multiple_acceptances_mailer)
      end

      it 'sends the initial multiple acceptances ucas_match email and records the action taken' do
        described_class.new(ucas_match).call

        expect(SupportInterface::SendUCASMatchInitialEmailsMultipleAcceptances).to have_received(:new).with(ucas_match)
        expect(ucas_match.action_taken).to eq('initial_emails_sent')
      end
    end

    context 'when the applicant has applied to both UCAS and Apply' do
      before do
        allow(ucas_match).to receive(:dual_application_or_dual_acceptance?).and_return(true)
        allow(SupportInterface::SendUCASMatchInitialEmailsDuplicateApplications).to receive(:new).with(ucas_match).and_return(duplicate_applications_mailer)
      end

      it 'sends the initial duplicate applications ucas_match email and records the action taken' do
        described_class.new(ucas_match).call

        expect(SupportInterface::SendUCASMatchInitialEmailsDuplicateApplications).to have_received(:new).with(ucas_match)
        expect(ucas_match.action_taken).to eq('initial_emails_sent')
      end
    end
  end
end
