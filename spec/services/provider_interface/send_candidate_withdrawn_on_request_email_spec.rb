require 'rails_helper'

RSpec.describe ProviderInterface::SendCandidateWithdrawnOnRequestEmail do
  describe '#call' do
    let(:mailer) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    it 'calls CandidateMailer.application_withdrawn_on_request when all applications are withdrawn' do
      allow(CandidateMailer).to receive(:application_withdrawn_on_request).and_return(mailer)

      described_class.new(application_choice: create(:application_choice, :withdrawn)).call

      expect(CandidateMailer).to have_received(:application_withdrawn_on_request)
    end

    it 'calls CandidateMailer.application_withdrawn_on_request when all applications are awaiting decision' do
      allow(CandidateMailer).to receive(:application_withdrawn_on_request).and_return(mailer)

      described_class.new(application_choice: create(:application_choice, :awaiting_provider_decision)).call

      expect(CandidateMailer).to have_received(:application_withdrawn_on_request)
    end

    it 'calls CandidateMailer.application_withdrawn_on_request when all applications have offers' do
      allow(CandidateMailer).to receive(:application_withdrawn_on_request).and_return(mailer)

      described_class.new(application_choice: create(:application_choice, :offered)).call

      expect(CandidateMailer).to have_received(:application_withdrawn_on_request)
    end

    it 'calls CandidateMailer.application_withdrawn_on_request when one application has an offer and another is awaiting decision' do
      allow(CandidateMailer).to receive(:application_withdrawn_on_request).and_return(mailer)
      offered = create(:application_choice, :offered)
      create(:application_choice, :awaiting_provider_decision, application_form: offered.application_form)

      described_class.new(application_choice: offered).call

      expect(CandidateMailer).to have_received(:application_withdrawn_on_request)
    end
  end
end
