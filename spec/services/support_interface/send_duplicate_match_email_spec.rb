require 'rails_helper'

RSpec.describe SupportInterface::SendDuplicateMatchEmail do
  describe '#call' do
    let(:fraud_match) { create(:fraud_match) }

    before do
      @candidate = fraud_match.candidates.first
      build(
        :application_form,
        candidate: @candidate,
      )

      mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(CandidateMailer).to receive(:fraud_match_email).and_return(mail)
    end

    it 'sends an email to the candidate' do
      described_class.new(@candidate).call
      expect(CandidateMailer).to have_received(:fraud_match_email).once
    end
  end
end
